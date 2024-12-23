import DashTypes
import DashlaneAPI
import Foundation
import StateMachine
import SwiftTreats

@MainActor
public struct SSORemoteStateMachine: StateMachine {

  public enum State: Hashable {
    case waitingForUserInput
    case failed(StateMachineError)
    case cancelled
    case completed(RemoteLoginSession)
  }

  public enum Event {
    case receivedSSOCallback(Result<SSOCompletion, Error>)
    case cancel
  }

  public var state: State = .waitingForUserInput

  private let cryptoEngineProvider: CryptoEngineProvider
  private let apiClient: AppAPIClient
  private let deviceInfo: DeviceInfo
  private let ssoAuthenticationInfo: SSOAuthenticationInfo
  private let logger: Logger

  public init(
    ssoAuthenticationInfo: SSOAuthenticationInfo,
    deviceInfo: DeviceInfo,
    apiClient: AppAPIClient,
    cryptoEngineProvider: CryptoEngineProvider,
    logger: Logger
  ) {
    self.ssoAuthenticationInfo = ssoAuthenticationInfo
    self.apiClient = apiClient
    self.deviceInfo = deviceInfo
    self.cryptoEngineProvider = cryptoEngineProvider
    self.logger = logger
  }

  public mutating func transition(with event: Event) async {
    logger.logInfo("Received event \(event)")
    switch (state, event) {
    case (.waitingForUserInput, let .receivedSSOCallback(result)):
      await handleSSOCallbackResult(result)
    case (_, .cancel):
      state = .cancelled
    default:
      let errorMessage = "Unexpected \(event) event for the state \(state)"
      logger.error(errorMessage)
    }
    logger.logInfo("Transition to state: \(state)")
  }

  private mutating func handleSSOCallbackResult(_ result: Result<SSOCompletion, Error>) async {
    do {
      let result = try result.get()
      switch result {
      case let .completed(ssoCallbackInfos):
        await validateSSOTokenAndGetKeys(
          ssoCallbackInfos.ssoToken, serviceProviderKey: ssoCallbackInfos.serviceProviderKey)
      case .cancel:
        state = .cancelled
      }
    } catch {
      logger.error("SSO authentication failed", error: error)
      state = .failed(StateMachineError(underlyingError: error))
    }
  }

  private mutating func validateSSOTokenAndGetKeys(_ token: String, serviceProviderKey: String)
    async
  {
    do {
      let verificationResponse = try await self.apiClient.authentication.performSsoVerification(
        login: ssoAuthenticationInfo.login.email, ssoToken: token)
      let deviceRegistrationResponse = try await self.apiClient.authentication
        .completeDeviceRegistrationWithAuthTicket(
          device: self.deviceInfo, login: self.ssoAuthenticationInfo.login.email,
          authTicket: verificationResponse.authTicket)
      let deviceRegistrationData = DeviceRegistrationData(
        initialSettings: deviceRegistrationResponse.settings.content,
        deviceAccessKey: deviceRegistrationResponse.deviceAccessKey,
        deviceSecretKey: deviceRegistrationResponse.deviceSecretKey,
        analyticsIds: deviceRegistrationResponse.analyticsIds,
        authTicket: verificationResponse.authTicket,
        serverKey: deviceRegistrationResponse.serverKey,
        remoteKeys: deviceRegistrationResponse.remoteKeys,
        ssoServerKey: deviceRegistrationResponse.ssoServerKey
      )
      let (encryptedRemoteKey, ssoKey) = try deviceRegistrationResponse.encryptedRemoteKeyAndSSOKey(
        usingKey: serviceProviderKey)
      let cryptoEngine = try cryptoEngineProvider.cryptoEngine(forKey: ssoKey)
      let decryptedRemoteKey = try cryptoEngine.decrypt(encryptedRemoteKey)
      let ssoKeys = SSOKeys(
        remoteKey: decryptedRemoteKey, ssoKey: ssoKey,
        authTicket: AuthTicket(value: verificationResponse.authTicket))
      logger.logInfo("SSO token validated")
      try await validateSSOKey(
        ssoKeys.ssoKey, authTicket: AuthTicket(value: verificationResponse.authTicket),
        remoteKey: decryptedRemoteKey, data: deviceRegistrationData)
    } catch {
      state = .failed(StateMachineError(underlyingError: error))
      logger.error("SSO validation failed", error: error)
    }
  }

  private mutating func validateSSOKey(
    _ ssoKey: Data,
    authTicket: AuthTicket,
    remoteKey: Data,
    data: DeviceRegistrationData
  ) async throws {

    let authentication = ServerAuthentication(
      deviceAccessKey: data.deviceAccessKey, deviceSecretKey: data.deviceSecretKey)

    let userDeviceAPIClient = apiClient.makeUserClient(
      login: ssoAuthenticationInfo.login,
      signedAuthentication: authentication.signedAuthentication)

    let cryptoConfig = try await cryptoEngineProvider.retriveCryptoConfig(
      with: .ssoKey(ssoKey),
      remoteKey: remoteKey,
      encryptedSettings: data.initialSettings,
      userDeviceAPIClient: userDeviceAPIClient)

    let remoteLoginSession = RemoteLoginSession(
      login: ssoAuthenticationInfo.login,
      userData: data,
      cryptoConfig: cryptoConfig,
      masterKey: .ssoKey(ssoKey),
      authentication: authentication,
      remoteKey: remoteKey,
      isRecoveryLogin: false,
      newMasterPassword: nil,
      authTicket: authTicket,
      verificationMethod: nil,
      pin: nil,
      shouldEnableBiometry: false,
      isBackupCode: false)
    self.state = .completed(remoteLoginSession)
    logger.logInfo("Transition to state: \(state)")

  }

}

extension AppAPIClient.Authentication.CompleteDeviceRegistrationWithAuthTicket.Response {
  func encryptedRemoteKeyAndSSOKey(usingKey serviceProviderKey: String) throws -> (Data, Data) {
    guard let remoteKey = remoteKeys?.ssoRemoteKey(),
      let ssoServerKey = ssoServerKey
    else {
      throw SSOAccountError.userDataNotFetched
    }

    guard let serverKeyData = Data(base64Encoded: ssoServerKey),
      let serviceProviderKeyData = Data(base64Encoded: serviceProviderKey),
      let remoteKeyData = Data(base64Encoded: remoteKey.key)
    else {
      throw SSOAccountError.invalidServiceProviderKey
    }
    let ssoKey = serverKeyData ^ serviceProviderKeyData
    return (remoteKeyData, ssoKey)
  }
}
