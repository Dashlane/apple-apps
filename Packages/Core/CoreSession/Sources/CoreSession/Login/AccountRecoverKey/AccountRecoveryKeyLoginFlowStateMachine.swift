import CoreNetworking
import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation
import StateMachine

public struct AccountRecoveryKeyLoginFlowStateMachine: StateMachine {

  public enum Error: Swift.Error {
    case verificationFailed
    case wrongRecoveryKey
    case cannotConvertFromBase64
    case cannotDecodeMasterKey
  }

  public enum LoginType: Hashable, Sendable {
    case remote(AuthTicket)
    case deviceToDevice(DeviceInfo)
    case local(_ user: MPUserAccountUnlockMode, DeviceInfo)
  }

  public struct Completion: Hashable, Sendable {
    public let masterKey: MasterKey
    public let authTicket: AuthTicket
    public let newMasterPassword: String?
    public let isBackupCode: Bool
    public let verificationMethod: VerificationMethod
  }

  @Loggable
  public enum State: Hashable, Sendable {
    case loading
    case error(StateMachineError)
    case accountVerification(VerificationMethod, DeviceInfo)
    case recoveryKeyInput(AuthTicket, AccountType)
    case masterPasswordChangeNeeded(MasterKey, AuthTicket)
    case completed(AccountRecoveryKeyLoginFlowStateMachine.Completion)
    case cancel
  }

  @Loggable
  public enum Event: Sendable {
    case start
    case errorEncountered(StateMachineError)
    case accountVerified(AuthTicket, isBackupCode: Bool, VerificationMethod)
    case masterPasswordChanged(MasterKey, AuthTicket, newMasterPassword: String)
    case getMasterKey(recoveryKey: String, AuthTicket)
    case masterKeyReceived(MasterKey, AuthTicket)
    case cancel
  }

  public private(set) var state: State

  private let login: Login
  private let loginType: LoginType
  private let accountType: AccountType
  private let appAPIClient: AppAPIClient
  private var isBackupCode = false
  private var verificationMethod: VerificationMethod = .emailToken
  private let logger: Logger
  private let cryptoEngineProvider: CryptoEngineProvider

  public init(
    initialState: AccountRecoveryKeyLoginFlowStateMachine.State,
    login: Login,
    loginType: LoginType,
    accountType: AccountType,
    appAPIClient: AppAPIClient,
    cryptoEngineProvider: CryptoEngineProvider,
    logger: Logger
  ) {
    self.state = initialState
    self.login = login
    self.loginType = loginType
    self.appAPIClient = appAPIClient
    self.accountType = accountType
    self.logger = logger
    self.cryptoEngineProvider = cryptoEngineProvider
  }

  public mutating func transition(with event: Event) async throws {
    switch event {
    case .start:
      await start()
    case let .errorEncountered(error):
      state = .error(error)
    case let .accountVerified(authTicket, isBackupCode, verificationMethod):
      self.isBackupCode = isBackupCode
      self.verificationMethod = verificationMethod
      state = .recoveryKeyInput(authTicket, accountType)
    case let .masterPasswordChanged(masterKey, authTicket, newMasterPassword):
      state = .completed(
        Completion(
          masterKey: masterKey, authTicket: authTicket, newMasterPassword: newMasterPassword,
          isBackupCode: isBackupCode, verificationMethod: verificationMethod))
    case .getMasterKey(let recoveryKey, let authTicket):
      do {
        let masterKey = try await masterKey(using: recoveryKey, authTicket: authTicket)
        try await transition(with: .masterKeyReceived(masterKey, authTicket))
      } catch {
        state = .error(.init(underlyingError: Error.wrongRecoveryKey))
      }
    case .masterKeyReceived(let masterKey, let authTicket):
      if case .masterPassword = accountType {
        state = .masterPasswordChangeNeeded(masterKey, authTicket)
      } else {
        state = .completed(
          Completion(
            masterKey: masterKey, authTicket: authTicket, newMasterPassword: nil,
            isBackupCode: isBackupCode, verificationMethod: verificationMethod))
      }
    case .cancel:
      state = .cancel
    }
    let state = state
    logger.info("Transition to state: \(state)")
  }

  private mutating func start() async {
    switch loginType {
    case let .remote(authTicket):
      state = .recoveryKeyInput(authTicket, accountType)
    case let .deviceToDevice(deviceInfo):
      await makeVerificationMethod(login: login, deviceInfo: deviceInfo)
    case let .local(user, deviceInfo):
      if let authTicket = user.accountRecoveryAuthTicket {
        state = .recoveryKeyInput(authTicket, accountType)
      } else {
        await makeVerificationMethod(login: login, deviceInfo: deviceInfo)
      }
    }
  }

  private mutating func makeVerificationMethod(login: Login, deviceInfo: DeviceInfo) async {
    do {
      let method =
        try await appAPIClient.authentication
        .get2FAStatusUnauthenticated(login: login.email)
        .verificationMethod ?? .emailToken
      state = .accountVerification(method, deviceInfo)
    } catch {
      state = .error(.init(underlyingError: Error.verificationFailed))
    }
  }

  public func masterKey(using recoveryKey: AccountRecoveryKey, authTicket: AuthTicket) async throws
    -> MasterKey
  {
    let encryptedVaultKey = try await appAPIClient.accountrecovery.getEncryptedVaultKey(
      login: login.email, authTicket: authTicket.value
    ).encryptedVaultKey
    guard let encryptedVaultKeyData = Data(base64Encoded: encryptedVaultKey) else {
      throw Error.cannotConvertFromBase64
    }

    let cryptoEngine = try cryptoEngineProvider.cryptoEngine(
      forEncryptedVaultKey: encryptedVaultKeyData, recoveryKey: recoveryKey)

    let decryptedData = try cryptoEngine.decrypt(encryptedVaultKeyData)
    guard let decryptedMasterKey = String(data: decryptedData, encoding: .utf8) else {
      throw Error.cannotDecodeMasterKey
    }

    return .masterPassword(decryptedMasterKey)
  }
}

extension AccountRecoveryKeyLoginFlowStateMachine {
  public func makeAccountVerificationStateMachine() -> AccountVerificationStateMachine {
    AccountVerificationStateMachine(
      state: .initialize, login: login, verificationMethod: verificationMethod,
      appAPIClient: appAPIClient, logger: logger)
  }
}

extension AccountRecoveryKeyLoginFlowStateMachine {
  public static var mock: AccountRecoveryKeyLoginFlowStateMachine {
    AccountRecoveryKeyLoginFlowStateMachine(
      initialState: .loading, login: Login("_"), loginType: .local(.masterPasswordOnly, .mock),
      accountType: .masterPassword, appAPIClient: .fake, cryptoEngineProvider: .mock(),
      logger: .mock)
  }
}
