import DashTypes
import DashlaneAPI
import Foundation
import SwiftTreats

public class RemoteLoginHandler {
  public enum Error: Swift.Error, Equatable {
    case wrongMasterKey
    case userDataNotFetched
    case invalidServiceProviderKey
    case invalidSettings
  }

  public enum CompletionType: Hashable {
    public static func == (
      lhs: RemoteLoginHandler.CompletionType, rhs: RemoteLoginHandler.CompletionType
    ) -> Bool {
      lhs.hashValue == rhs.hashValue
    }

    public func hash(into hasher: inout Hasher) {
      hasher.combine(id)
    }

    public var id: String {
      switch self {
      case .deviceUnlinking:
        return "deviceUnlinking"
      case .completed:
        return "completed"
      case .migrateAccount:
        return "migrateAccount"
      }
    }
    case deviceUnlinking(DeviceUnlinker, session: RemoteLoginSession)
    case completed(RemoteLoginConfiguration)
    case migrateAccount(AccountMigrationInfos)
  }

  private let logger: Logger
  private let apiclient: AppAPIClient
  private let sessionsContainer: SessionsContainerProtocol
  private let deviceInfo: DeviceInfo
  private let ssoInfo: SSOInfo?
  private let cryptoEngineProvider: CryptoEngineProvider

  init(
    deviceInfo: DeviceInfo,
    ssoInfo: SSOInfo? = nil,
    apiclient: AppAPIClient,
    sessionsContainer: SessionsContainerProtocol,
    logger: Logger,
    cryptoEngineProvider: CryptoEngineProvider
  ) {
    self.apiclient = apiclient
    self.sessionsContainer = sessionsContainer
    self.logger = logger
    self.deviceInfo = deviceInfo
    self.ssoInfo = ssoInfo
    self.cryptoEngineProvider = cryptoEngineProvider
  }

  public func loadAccount(with session: RemoteLoginSession) async throws
    -> RemoteLoginHandler.CompletionType
  {

    let userDeviceAPIClient = apiclient.makeUserClient(
      login: session.login,
      signedAuthentication: session.authentication.signedAuthentication)

    #if targetEnvironment(macCatalyst)
      _ = try await userDeviceAPIClient.pairing.requestPairing()
    #endif

    if let completion = try await checkDeviceLimit(
      for: session, userDeviceAPIClient: userDeviceAPIClient)
    {
      return completion
    }
    return try await self.loadSession(session)
  }

  private func checkDeviceLimit(
    for session: RemoteLoginSession,
    userDeviceAPIClient: UserDeviceAPIClient
  ) async throws -> CompletionType? {
    let unlinker = DeviceUnlinker(session: session, userDeviceAPIClient: userDeviceAPIClient)

    try await unlinker.refreshLimitAndDevices()
    if unlinker.mode != nil {
      return .deviceUnlinking(unlinker, session: session)
    } else {
      return nil
    }
  }

  @discardableResult
  private func loadSession(_ remoteLoginSession: RemoteLoginSession) async throws -> CompletionType
  {
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

    return try await self.createSession(
      with: configuration,
      remoteLoginSession: remoteLoginSession)
  }

  private func createSession(
    with sessionConfig: SessionConfiguration,
    remoteLoginSession: RemoteLoginSession
  ) async throws -> CompletionType {
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
      return .migrateAccount(
        AccountMigrationInfos(
          session: session,
          type: type, ssoAuthenticationInfo: ssoAuthenticationInfo,
          authTicket: remoteLoginSession.authTicket))
    }
    return .completed(
      RemoteLoginConfiguration(
        session: session,
        pinCode: remoteLoginSession.pin,
        isRecoveryLogin: remoteLoginSession.isRecoveryLogin,
        shouldEnableBiometry: remoteLoginSession.shouldEnableBiometry,
        newMasterPassword: remoteLoginSession.newMasterPassword))
  }

  public func load(_ remoteLoginSession: RemoteLoginSession) async throws -> Session {
    let type = try await self.loadSession(remoteLoginSession)
    guard case let .completed(session) = type else {
      throw Error.userDataNotFetched
    }
    return session.session
  }
}

public struct RemoteLoginConfiguration {
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
