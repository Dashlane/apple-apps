import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation
import StateMachine

public struct MasterPasswordInputRemoteStateMachine: StateMachine {

  @Loggable
  public enum State: Hashable, Sendable {
    case waitingForUserInput(_ isAccountRecoveryEnabled: Bool)
    case accountRecovery(AuthTicket)
    case accountRecoveryCancelled
    case completed(RemoteLoginSession)
    case failed(StateMachineError, _ isBackupCode: Bool, VerificationMethod)
  }

  @Loggable
  public enum Event: Sendable {
    case fetchAccountRecoveryKeyStatus
    case validateMasterPassword(_ masterPassword: String)
    case startAccountRecovery
    case accountRecoveryDidFinish(AccountRecoveryKeyLoginFlowStateMachine.Completion)
    case cancelAccountRecovery
  }

  public var state: State

  private let cryptoEngineProvider: CryptoEngineProvider
  private let appAPIClient: AppAPIClient
  private let login: Login
  private let data: DeviceRegistrationData
  private let logger: Logger

  public init(
    state: MasterPasswordInputRemoteStateMachine.State,
    login: Login,
    data: DeviceRegistrationData,
    appAPIClient: AppAPIClient,
    cryptoEngineProvider: CryptoEngineProvider,
    logger: Logger
  ) {
    self.state = state
    self.login = login
    self.cryptoEngineProvider = cryptoEngineProvider
    self.data = data
    self.appAPIClient = appAPIClient
    self.logger = logger
  }

  public mutating func transition(with event: Event) async throws {
    switch event {
    case .fetchAccountRecoveryKeyStatus:
      await fetchAccountRecoveryKeyStatus()
    case let .accountRecoveryDidFinish(result):
      await validateMaterKey(
        result.masterKey, newMasterPassword: result.newMasterPassword,
        isBackupCode: result.isBackupCode, verificationMethod: result.verificationMethod)
    case let .validateMasterPassword(masterPassword):
      await validateMaterPassword(
        masterPassword, isBackupCode: data.isBackupCode,
        verificationMethod: data.verificationMethod ?? .emailToken)
    case .startAccountRecovery:
      state = .accountRecovery(data.authTicket)
    case .cancelAccountRecovery:
      state = .accountRecoveryCancelled
    }
    let state = state
    logger.info("Transition to state: \(state)")
  }

  mutating func fetchAccountRecoveryKeyStatus() async {
    let response = try? await appAPIClient.accountrecovery.getStatus(login: login.email)
    state = .waitingForUserInput(response?.enabled ?? false)
  }

  private mutating func validateMaterPassword(
    _ masterPassword: String,
    isBackupCode: Bool,
    verificationMethod: VerificationMethod,
    newMasterPassword: String? = nil
  ) async {
    let masterKey = CoreSession.MasterKey.masterPassword(masterPassword, serverKey: data.serverKey)
    await self.validateMaterKey(
      masterKey, newMasterPassword: newMasterPassword, isBackupCode: isBackupCode,
      verificationMethod: verificationMethod)
  }

  private mutating func validateMaterKey(
    _ masterKey: MasterKey,
    newMasterPassword: String? = nil,
    isBackupCode: Bool,
    verificationMethod: VerificationMethod
  ) async {

    let remoteKey: Data? =
      if let remoteKey = data.masterPasswordRemoteKey,
        let remoteKeyData = Data(base64Encoded: remoteKey.key),
        let cryptoEngine = try? cryptoEngineProvider.sessionCryptoEngine(
          forEncryptedPayload: remoteKeyData,
          masterKey: masterKey),
        let decipheredRemoteKey = try? cryptoEngine.decrypt(remoteKeyData)
      {
        decipheredRemoteKey
      } else {
        nil
      }

    let authentication = ServerAuthentication(
      deviceAccessKey: data.deviceAccessKey, deviceSecretKey: data.deviceSecretKey)

    let userDeviceAPIClient = appAPIClient.makeUserClient(
      login: login,
      signedAuthentication: authentication.signedAuthentication)

    do {
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
        isRecoveryLogin: newMasterPassword != nil,
        newMasterPassword: newMasterPassword,
        authTicket: data.authTicket,
        verificationMethod: verificationMethod,
        pin: nil,
        shouldEnableBiometry: false,
        isBackupCode: isBackupCode)
      self.state = .completed(remoteLoginSession)
    } catch {
      self.state = .failed(
        StateMachineError(underlyingError: RemoteLoginStateMachine.Error.wrongMasterKey),
        isBackupCode, verificationMethod)
      logger.error("Device registration failed", error: error)
    }
  }
}

extension MasterPasswordInputRemoteStateMachine {
  public func makeAccountRecoveryKeyLoginFlowStateMachine(
    loginType: AccountRecoveryKeyLoginFlowStateMachine.LoginType
  ) -> AccountRecoveryKeyLoginFlowStateMachine {
    AccountRecoveryKeyLoginFlowStateMachine(
      initialState: .loading, login: login, loginType: loginType, accountType: .masterPassword,
      appAPIClient: appAPIClient, cryptoEngineProvider: cryptoEngineProvider, logger: logger)
  }
}

extension MasterPasswordInputRemoteStateMachine {

  public static var mock: MasterPasswordInputRemoteStateMachine {
    MasterPasswordInputRemoteStateMachine(
      state: .waitingForUserInput(true), login: Login("_"), data: .mock,
      appAPIClient: .mock({

      }), cryptoEngineProvider: .mock(), logger: .mock)
  }
}
