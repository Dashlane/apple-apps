import CoreTypes
import DashlaneAPI
import LogFoundation
import UIKit

public protocol RegularAccountCreationServiceProtocol: Sendable {
  func createAccount(using configuration: AccountCreationConfiguration) async throws -> Session
}

public actor RegularAccountCreationService: RegularAccountCreationServiceProtocol {
  let sessionsContainer: SessionsContainerProtocol
  let sessionCleaner: SessionCleanerProtocol
  let appAPIClient: AppAPIClient
  let sessionCryptoEngineProvider: CryptoEngineProvider
  let logger: Logger
  let accountCreationSettingsProvider: AccountCreationSettingsProvider
  let accountCreationSharingKeysProvider: AccountCreationSharingKeysProvider

  public init(
    sessionsContainer: SessionsContainerProtocol,
    sessionCleaner: SessionCleanerProtocol,
    accountCreationSettingsProvider: AccountCreationSettingsProvider,
    accountCreationSharingKeysProvider: AccountCreationSharingKeysProvider,
    appAPIClient: AppAPIClient,
    sessionCryptoEngineProvider: CryptoEngineProvider,
    logger: Logger
  ) {
    self.sessionsContainer = sessionsContainer
    self.sessionCleaner = sessionCleaner
    self.appAPIClient = appAPIClient
    self.sessionCryptoEngineProvider = sessionCryptoEngineProvider
    self.logger = logger
    self.accountCreationSettingsProvider = accountCreationSettingsProvider
    self.accountCreationSharingKeysProvider = accountCreationSharingKeysProvider
  }

  public func createAccount(using configuration: AccountCreationConfiguration) async throws
    -> Session
  {
    let sessionCryptoEngine = try sessionCryptoEngineProvider.sessionCryptoEngine(
      for: .masterPassword(configuration.password))
    let cryptoConfig = sessionCryptoEngine.config

    let settings = try accountCreationSettingsProvider.initialSettings(
      using: cryptoConfig, remoteCryptoEngine: sessionCryptoEngine,
      login: Login(configuration.email.address))

    let consents = [
      Consent(
        consentType: .emailsOffersAndTips, status: configuration.hasUserAcceptedEmailMarketing),
      Consent(consentType: .privacyPolicyAndToS, status: true),
    ]

    let sharingKeys = try accountCreationSharingKeysProvider.sharingKeys(using: sessionCryptoEngine)

    let creationInfo = AccountCreationInfo(
      email: configuration.email.address,
      appVersion: Application.version(),
      settings: settings,
      consents: consents,
      sharingKeys: sharingKeys,
      origin: .iOS,
      accountType: configuration.accountType)
    let accountInfo = try await appAPIClient.account.createAccount(with: creationInfo)

    let login = Login(creationInfo.login)
    let configuration = SessionConfiguration(
      login: login,
      masterKey: .masterPassword(configuration.password, serverKey: nil),
      keys: SessionSecureKeys(
        serverAuthentication: ServerAuthentication(
          deviceAccessKey: accountInfo.deviceAccessKey, deviceSecretKey: accountInfo.deviceSecretKey
        ),
        remoteKey: nil,
        analyticsIds: AnalyticsIdentifiers(
          device: accountInfo.deviceAnalyticsId, user: accountInfo.userAnalyticsId)),
      info: SessionInfo(
        deviceAccessKey: accountInfo.deviceAccessKey,
        loginOTPOption: nil,
        accountType: try AccountType(configuration.accountType)))

    sessionCleaner.removeLocalData(for: login)
    return try sessionsContainer.createSession(with: configuration, cryptoConfig: cryptoConfig)
  }
}

struct FakeRegularAccountCreationService: RegularAccountCreationServiceProtocol {

  let session: Session?

  func createAccount(using configuration: AccountCreationConfiguration) async throws -> Session {
    guard let session else { throw AccountError.unknown }
    return session
  }
}

extension RegularAccountCreationServiceProtocol where Self == FakeRegularAccountCreationService {
  static func mock(session: Session? = .mock) -> RegularAccountCreationServiceProtocol {
    FakeRegularAccountCreationService(session: session)
  }
}
