import DashTypes
import DashlaneAPI
import Foundation
import StateMachine
import SwiftTreats

@MainActor
public struct RemoteLoginStateMachine: StateMachine {

  public enum Error: Swift.Error, Equatable {
    case wrongMasterKey
    case userDataNotFetched
    case invalidServiceProviderKey
    case invalidSettings
  }

  public enum State: Hashable {
    case authentication(RemoteLoginType)
    case deviceUnlink(DeviceUnlinker, RemoteLoginSession)
    case migrateAccount(AccountMigrationInfos)
    case completed(RemoteLoginConfiguration)
    case cancelled
    case logout
    case failed(StateMachineError)
  }

  public enum Event {
    case initialize
    case cancel
    case logout
    case deviceTransferDidFinish(RemoteLoginSession)
    case regularLoginDidFinish(RemoteLoginSession)
    case deviceUnlinkDidFinish(RemoteLoginSession)
    case failed(StateMachineError)
  }

  public var state: State

  private let logger: Logger
  private let apiclient: AppAPIClient
  private let sessionsContainer: SessionsContainerProtocol
  private let deviceInfo: DeviceInfo
  private let ssoInfo: SSOInfo?
  private let cryptoEngineProvider: CryptoEngineProvider
  private let type: RemoteLoginType

  public init(
    type: RemoteLoginType,
    deviceInfo: DeviceInfo,
    ssoInfo: SSOInfo? = nil,
    apiclient: AppAPIClient,
    sessionsContainer: SessionsContainerProtocol,
    logger: Logger,
    cryptoEngineProvider: CryptoEngineProvider
  ) {
    self.type = type
    self.apiclient = apiclient
    self.sessionsContainer = sessionsContainer
    self.logger = logger
    self.deviceInfo = deviceInfo
    self.ssoInfo = ssoInfo
    self.cryptoEngineProvider = cryptoEngineProvider
    self.state = .authentication(type)
  }

  public mutating func transition(with event: Event) async {
    logger.logInfo("Received event \(event)")
    switch event {
    case .initialize:
      state = .authentication(type)
    case .cancel:
      state = .cancelled
    case .logout:
      state = .logout
    case let .deviceTransferDidFinish(session):
      await loadAccount(with: session)
    case let .regularLoginDidFinish(session):
      await loadAccount(with: session)
    case let .deviceUnlinkDidFinish(session):
      do {
        try await loadSession(session)
      } catch {
        state = .failed(StateMachineError(underlyingError: error))
      }
    case let .failed(error):
      state = .failed(error)
    }
  }

  private mutating func loadAccount(with session: RemoteLoginSession) async {
    do {
      let userDeviceAPIClient = apiclient.makeUserClient(
        login: session.login,
        signedAuthentication: session.authentication.signedAuthentication)

      #if targetEnvironment(macCatalyst)
        _ = try await userDeviceAPIClient.pairing.requestPairing()
      #endif

      guard
        let unlinker = try await checkDeviceLimit(
          for: session, userDeviceAPIClient: userDeviceAPIClient)
      else {
        try await self.loadSession(session)
        return
      }
      self.state = .deviceUnlink(unlinker, session)
    } catch {
      state = .failed(StateMachineError(underlyingError: error))
    }
  }

  private func checkDeviceLimit(
    for session: RemoteLoginSession,
    userDeviceAPIClient: UserDeviceAPIClient
  ) async throws -> DeviceUnlinker? {
    let unlinker = DeviceUnlinker(session: session, userDeviceAPIClient: userDeviceAPIClient)

    try await unlinker.refreshLimitAndDevices()
    if unlinker.mode != nil {
      return unlinker
    } else {
      return nil
    }
  }

  private mutating func loadSession(_ remoteLoginSession: RemoteLoginSession) async throws {
    let loginResponse =
      try await apiclient
      .authentication
      .getAuthenticationMethodsForLogin(
        login: remoteLoginSession.login.email,
        deviceAccessKey: remoteLoginSession.userData.deviceAccessKey,
        methods: [
          .emailToken,
          .totp,
          .duoPush,
        ],
        profiles: [
          AuthenticationMethodsLoginProfiles(
            login: remoteLoginSession.login.email,
            deviceAccessKey: remoteLoginSession.userData.deviceAccessKey
          )
        ],
        u2fSecret: nil
      )

    let loginOTPOption: ThirdPartyOTPOption? = loginResponse.verifications.loginMethod(
      for: remoteLoginSession.login
    )?.otpOption

    let configuration = SessionConfiguration(
      login: remoteLoginSession.login,
      masterKey: remoteLoginSession.masterKey,
      keys: SessionSecureKeys(
        serverAuthentication: remoteLoginSession.authentication,
        remoteKey: remoteLoginSession.remoteKey,
        analyticsIds: remoteLoginSession.userData.analyticsIds
      ),
      info: SessionInfo(
        deviceAccessKey: remoteLoginSession.userData.deviceAccessKey,
        loginOTPOption: loginOTPOption,
        accountType: try loginResponse.userAccountType
      )
    )

    try await self.createSession(
      with: configuration,
      remoteLoginSession: remoteLoginSession)
  }

  private mutating func createSession(
    with sessionConfig: SessionConfiguration,
    remoteLoginSession: RemoteLoginSession
  ) async throws {
    logger.debug(
      "Creating remote session with crypto: \(String(describing: remoteLoginSession.cryptoConfig))")

    let session = try self.sessionsContainer.createSession(
      with: sessionConfig, cryptoConfig: remoteLoginSession.cryptoConfig)

    if let ssoMigration = self.ssoInfo,
      let type = self.ssoInfo?.migration,
      let serviceProviderUrl = URL(
        string:
          "\(ssoMigration.serviceProviderUrl)?redirect=mobile&username=\(remoteLoginSession.login.email)&frag=true"
      )
    {
      let ssoAuthenticationInfo = SSOAuthenticationInfo(
        login: remoteLoginSession.login,
        serviceProviderUrl: serviceProviderUrl,
        isNitroProvider: ssoMigration.isNitroProvider ?? false,
        migration: type
      )
      self.state = .migrateAccount(
        AccountMigrationInfos(
          session: session,
          type: type, ssoAuthenticationInfo: ssoAuthenticationInfo,
          authTicket: remoteLoginSession.authTicket))
      return
    }
    self.state = .completed(
      RemoteLoginConfiguration(
        session: session,
        pinCode: remoteLoginSession.pin,
        isRecoveryLogin: remoteLoginSession.isRecoveryLogin,
        shouldEnableBiometry: remoteLoginSession.shouldEnableBiometry,
        newMasterPassword: remoteLoginSession.newMasterPassword))
  }
}

public struct RemoteLoginConfiguration: Hashable {
  public let session: Session
  public let pinCode: String?
  public let isRecoveryLogin: Bool
  public let shouldEnableBiometry: Bool
  public let newMasterPassword: String?
  public init(
    session: Session,
    pinCode: String? = nil,
    isRecoveryLogin: Bool = false,
    shouldEnableBiometry: Bool = false,
    newMasterPassword: String? = nil
  ) {
    self.session = session
    self.pinCode = pinCode
    self.isRecoveryLogin = isRecoveryLogin
    self.shouldEnableBiometry = shouldEnableBiometry
    self.newMasterPassword = newMasterPassword
  }
}
