import DashTypes
import DashlaneAPI
import Foundation
import SwiftTreats

public class RegularRemoteLoginHandler {
  public enum Error: Swift.Error, Equatable {
    case wrongMasterKey
    case userDataNotFetched
    case invalidServiceProviderKey
  }

  public enum Step {
    case validateByDeviceRegistrationMethod(DeviceRegistrationValidatorEnumeration)
    case validateMasterPassword(DeviceRegistrationData)
    case completed(RemoteLoginSession)
  }

  private let logger: Logger
  public let login: Login
  public internal(set) var step: Step
  private let sessionsContainer: SessionsContainerProtocol
  public let deviceInfo: DeviceInfo
  public let deviceRegistrationMethod: LoginMethod
  private let ssoInfo: SSOInfo?
  private let cryptoEngineProvider: CryptoEngineProvider
  private let appAPIClient: AppAPIClient

  init(
    login: Login,
    deviceRegistrationMethod: LoginMethod,
    deviceInfo: DeviceInfo,
    ssoInfo: SSOInfo? = nil,
    appAPIClient: AppAPIClient,
    sessionsContainer: SessionsContainerProtocol,
    logger: Logger,
    cryptoEngineProvider: CryptoEngineProvider
  ) {
    self.login = login
    self.sessionsContainer = sessionsContainer
    self.logger = logger
    self.deviceInfo = deviceInfo
    self.deviceRegistrationMethod = deviceRegistrationMethod
    self.ssoInfo = ssoInfo
    self.appAPIClient = appAPIClient
    self.cryptoEngineProvider = cryptoEngineProvider
    let validatorEnum: DeviceRegistrationValidatorEnumeration

    switch deviceRegistrationMethod {
    case .tokenByEmail:
      validatorEnum = .tokenByEmail
    case let .thirdPartyOTP(option, _):
      validatorEnum = .thirdPartyOTP(option)
    case let .loginViaSSO(ssoAuthenticationInfo):
      validatorEnum = .loginViaSSO(ssoAuthenticationInfo)

    case .authenticator:
      validatorEnum = .authenticator
    }

    step = .validateByDeviceRegistrationMethod(validatorEnum)
  }

  public func validateMasterKeyAndRegister(
    _ masterKey: MasterKey,
    authTicket: AuthTicket,
    remoteKey: Data? = nil,
    isRecoveryLogin: Bool = false,
    newMasterPassword: String? = nil
  ) async throws {

    let data = try await registerDevice(withAuthTicket: authTicket)

    let remoteLoginSession = try await validateMasterKey(
      masterKey,
      login: login,
      authTicket: authTicket,
      remoteKey: remoteKey,
      data: data,
      isRecoveryLogin: isRecoveryLogin,
      newMasterPassword: newMasterPassword)
    self.step = .completed(remoteLoginSession)
  }

  public func registerDevice(withAuthTicket authTicket: AuthTicket) async throws
    -> DeviceRegistrationData
  {
    let deviceRegistrationResponse = try await appAPIClient.authentication
      .completeDeviceRegistrationWithAuthTicket(
        device: deviceInfo, login: login.email, authTicket: authTicket.value)
    let deviceRegistrationData = DeviceRegistrationData(
      initialSettings: deviceRegistrationResponse.settings.content,
      deviceAccessKey: deviceRegistrationResponse.deviceAccessKey,
      deviceSecretKey: deviceRegistrationResponse.deviceSecretKey,
      analyticsIds: deviceRegistrationResponse.analyticsIds,
      serverKey: deviceRegistrationResponse.serverKey,
      remoteKeys: deviceRegistrationResponse.remoteKeys,
      authTicket: authTicket.value)
    self.step = .validateMasterPassword(deviceRegistrationData)
    return deviceRegistrationData
  }

  public func validateMasterKey(
    _ masterKey: MasterKey,
    login: Login,
    authTicket: AuthTicket,
    remoteKey: Data? = nil,
    data: DeviceRegistrationData,
    isRecoveryLogin: Bool,
    newMasterPassword: String? = nil
  ) async throws -> RemoteLoginSession {
    let masterKey = masterKey.masterKey(withServerKey: data.serverKey)

    let authentication = ServerAuthentication(
      deviceAccessKey: data.deviceAccessKey, deviceSecretKey: data.deviceSecretKey)

    let userDeviceAPIClient = appAPIClient.makeUserClient(
      login: login,
      signedAuthentication: authentication.signedAuthentication)

    let cryptoConfig = try await cryptoEngineProvider.retriveCryptoConfig(
      with: masterKey,
      remoteKey: remoteKey,
      encryptedSettings: data.initialSettings,
      userDeviceAPIClient: userDeviceAPIClient)

    let remoteLoginSession = RemoteLoginSession(
      login: login,
      userData: data,
      cryptoConfig: cryptoConfig,
      masterKey: masterKey,
      authentication: authentication,
      remoteKey: remoteKey,
      isRecoveryLogin: isRecoveryLogin,
      newMasterPassword: newMasterPassword,
      authTicket: authTicket,
      pin: nil,
      shouldEnableBiometry: false)
    self.step = .completed(remoteLoginSession)

    return remoteLoginSession

  }
}

extension RegularRemoteLoginHandler {
  public static var mock: RegularRemoteLoginHandler {
    return RegularRemoteLoginHandler(
      login: Login("_"),
      deviceRegistrationMethod: .authenticator,
      deviceInfo: .mock,
      appAPIClient: .fake,
      sessionsContainer: SessionsContainer<InMemorySessionStoreProvider>.mock,
      logger: LoggerMock(),
      cryptoEngineProvider: FakeCryptoEngineProvider()
    )
  }
}
