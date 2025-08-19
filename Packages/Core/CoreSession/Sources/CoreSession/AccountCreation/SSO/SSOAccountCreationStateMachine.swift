import CoreTypes
import CyrilKit
import DashlaneAPI
import Foundation
import LogFoundation
import StateMachine
import SwiftTreats

public struct SSOAccountCreationStateMachine: StateMachine {

  public enum State: Hashable, Sendable {
    case initial
    case waitingForUserAuthentication(serviceProviderUrl: URL, isNitroProvider: Bool)
    case waitingForUserConsent(ssoToken: String, serviceProviderKey: String)
    case accountCreated(Session)
    case accountCreationFailed(StateMachineError)
    case userAuthenticationFailed(StateMachineError)
    case cancelled
  }

  public enum Event: Hashable {
    case askUserAuthentication
    case userAuthenticationDidSucceed(ssoToken: String, serviceProviderKey: String)
    case createAccount(SSOAccountCreationConfig)
    case userAuthenticationFailed(StateMachineError)
    case cancel
  }

  public var state: State = .initial

  let login: Login
  let info: SSOLoginInfo
  let logger: Logger
  let appAPIClient: AppAPIClient
  let sessionContainer: SessionsContainerProtocol
  let sessionCryptoEngineProvider: CryptoEngineProvider
  let accountCreationSettingsProvider: AccountCreationSettingsProvider
  let accountCreationSharingKeysProvider: AccountCreationSharingKeysProvider

  public init(
    login: Login,
    info: SSOLoginInfo,
    logger: Logger,
    appAPIClient: AppAPIClient,
    sessionContainer: SessionsContainerProtocol,
    sessionCryptoEngineProvider: CryptoEngineProvider,
    accountCreationSettingsProvider: AccountCreationSettingsProvider,
    accountCreationSharingKeysProvider: AccountCreationSharingKeysProvider
  ) {
    self.login = login
    self.info = info
    self.logger = logger
    self.appAPIClient = appAPIClient
    self.sessionContainer = sessionContainer
    self.sessionCryptoEngineProvider = sessionCryptoEngineProvider
    self.accountCreationSettingsProvider = accountCreationSettingsProvider
    self.accountCreationSharingKeysProvider = accountCreationSharingKeysProvider
  }

  mutating public func transition(with event: Event) async throws {
    logger.info("Received event \(event)")
    switch (state, event) {
    case (.initial, .askUserAuthentication):
      state = .waitingForUserAuthentication(
        serviceProviderUrl: info.serviceProviderURL, isNitroProvider: info.isNitroProvider)
    case (
      .waitingForUserAuthentication,
      let .userAuthenticationDidSucceed(ssoToken: ssoToken, serviceProviderKey: serviceProviderKey)
    ):
      state = .waitingForUserConsent(ssoToken: ssoToken, serviceProviderKey: serviceProviderKey)
    case (.waitingForUserConsent, let .createAccount(infos)):
      await self.createAccount(with: infos)
    case (.waitingForUserAuthentication, let .userAuthenticationFailed(error)):
      state = .userAuthenticationFailed(error)
    case (_, .cancel):
      state = .cancelled
    default:
      let errorMessage: LogMessage = "Unexpected \(event) event for the state \(state)"
      logger.fatal(errorMessage)
      throw InvalidTransitionError<Self>(event: event, state: state)
    }
    let state = state
    logger.info("Transition to state: \(state)")
  }

  private mutating func createAccount(with config: SSOAccountCreationConfig) async {
    do {
      let serverKey = Data.random(ofSize: 64)
      guard
        let ssoKeys = try? SSOKeys.Keys(
          serverKey: serverKey, serviceProviderKey: config.serviceProviderKey)
      else {
        logger.error("Incorrect serviceProviderKey")
        throw AccountError.unknown
      }

      guard
        let sessionCryptoEngine = try? sessionCryptoEngineProvider.sessionCryptoEngine(
          for: .ssoKey(ssoKeys.ssoKey)),
        let remoteCryptoEngine = try? sessionCryptoEngineProvider.cryptoEngine(
          forKey: ssoKeys.remoteKey),
        let encryptedRemoteKey = try? sessionCryptoEngine.encrypt(ssoKeys.remoteKey)
      else {
        logger.error("Failed to encrypt remote key")
        throw AccountError.unknown
      }
      let cryptoConfig = sessionCryptoEngine.config

      let settings = try accountCreationSettingsProvider.initialSettings(
        using: cryptoConfig, remoteCryptoEngine: remoteCryptoEngine, login: login)

      let consents = [
        Consent(consentType: .emailsOffersAndTips, status: config.hasUserAcceptedEmailMarketing),
        Consent(
          consentType: .privacyPolicyAndToS, status: config.hasUserAcceptedTermsAndConditions),
      ]

      let sharingKeys = try accountCreationSharingKeysProvider.sharingKeys(
        using: remoteCryptoEngine)

      let creationInfo = SSOAccountCreationInfos(
        email: login.email,
        settings: settings,
        consents: consents,
        sharingKeys: sharingKeys,
        ssoToken: config.ssoToken,
        ssoServerKey: serverKey.base64EncodedString(),
        remoteKeys: [
          AppAPIClient.Account.CreateUserWithSSO.Body.RemoteKeysElement(
            uuid: UUID().uuidString.lowercased(),
            key: encryptedRemoteKey.base64EncodedString(),
            type: .sso)
        ])

      let session = try await self.createSSOAccount(
        with: creationInfo, ssoKey: ssoKeys.ssoKey, remoteKey: ssoKeys.remoteKey,
        cryptoConfig: cryptoConfig)
      state = .accountCreated(session)
    } catch {
      logger.error("Failed to create account", error: error)
      state = .accountCreationFailed(StateMachineError(underlyingError: error))
    }
  }

  private func createSSOAccount(
    with accountInfos: SSOAccountCreationInfos, ssoKey: Data, remoteKey: Data,
    cryptoConfig: CryptoRawConfig
  ) async throws -> Session {
    let accountInfo = try await self.appAPIClient.account.createSSOAccount(with: accountInfos)
    let authentication = ServerAuthentication(
      deviceAccessKey: accountInfo.deviceAccessKey, deviceSecretKey: accountInfo.deviceSecretKey)
    let sessionConfiguration = SessionConfiguration(
      login: Login(accountInfos.login),
      masterKey: .ssoKey(ssoKey),
      keys: SessionSecureKeys(
        serverAuthentication: authentication,
        remoteKey: remoteKey,
        analyticsIds: AnalyticsIdentifiers(
          device: accountInfo.deviceAnalyticsId, user: accountInfo.userAnalyticsId)),
      info: SessionInfo(
        deviceAccessKey: accountInfo.deviceAccessKey,
        loginOTPOption: nil,
        accountType: .sso))
    return try self.sessionContainer.createSession(
      with: sessionConfiguration, cryptoConfig: cryptoConfig)

  }
}

extension SSOAccountCreationInfos {
  init(
    email: String,
    settings: CoreSessionSettings,
    consents: [Consent],
    sharingKeys: AccountCreateUserSharingKeys,
    ssoToken: String,
    ssoServerKey: String,
    remoteKeys: [AppAPIClient.Account.CreateUserWithSSO.Body.RemoteKeysElement]
  ) {
    self.init(
      login: email,
      contactEmail: email,
      appVersion: Application.version(),
      platform: AccountCreateUserPlatform(rawValue: Platform.passwordManager.rawValue)
        ?? .serverIphone,
      settings: settings,
      deviceName: Device.name,
      country: System.country,
      language: System.language,
      sharingKeys: sharingKeys,
      consents: consents,
      ssoToken: ssoToken,
      ssoServerKey: ssoServerKey,
      remoteKeys: remoteKeys)
  }
}
