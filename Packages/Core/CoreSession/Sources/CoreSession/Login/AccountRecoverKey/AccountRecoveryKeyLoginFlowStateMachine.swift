import CoreNetworking
import DashTypes
import DashlaneAPI
import StateMachine

public struct AccountRecoveryKeyLoginFlowStateMachine: StateMachine {

  public enum Error: Swift.Error {
    case verificationFailed
    case wrongRecoveryKey
  }

  public enum LoginType: Hashable {
    case remote(AuthTicket)
    case deviceToDevice(DeviceInfo)
    case local(_ user: User, DeviceInfo)
  }

  public enum User: Hashable {
    case otp2User(AuthTicket)
    case normalUser

    var authTicket: AuthTicket? {
      switch self {
      case let .otp2User(authTicket):
        return authTicket
      case .normalUser:
        return nil
      }
    }

  }

  public struct Completion: Hashable {
    public let masterKey: MasterKey
    public let authTicket: AuthTicket
    public let newMasterPassword: String?
    public let isBackupCode: Bool
    public let verificationMethod: VerificationMethod
  }

  public enum State: Hashable {
    case loading
    case error(StateMachineError)
    case accountVerification(VerificationMethod, DeviceInfo)
    case recoveryKeyInput(AuthTicket)
    case masterPasswordChangeNeeded(MasterKey, AuthTicket)
    case completed(AccountRecoveryKeyLoginFlowStateMachine.Completion)
    case cancel
  }

  public enum Event {
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
  private let recoveryLoginService: AccountRecoveryKeyLoginService
  private var isBackupCode = false
  private var verificationMethod: VerificationMethod = .emailToken

  public init(
    initialState: AccountRecoveryKeyLoginFlowStateMachine.State,
    login: Login,
    loginType: LoginType,
    accountType: AccountType,
    appAPIClient: AppAPIClient,
    cryptoEngineProvider: CryptoEngineProvider
  ) {
    self.state = initialState
    self.login = login
    self.loginType = loginType
    self.appAPIClient = appAPIClient
    self.accountType = accountType
    self.recoveryLoginService = .init(
      login: login,
      appAPIClient: appAPIClient,
      cryptoEngineProvider: cryptoEngineProvider
    )
  }

  public mutating func transition(with event: Event) async {
    switch event {
    case .start:
      await start()
    case let .errorEncountered(error):
      state = .error(error)
    case let .accountVerified(authTicket, isBackupCode, verificationMethod):
      self.isBackupCode = isBackupCode
      self.verificationMethod = verificationMethod
      state = .recoveryKeyInput(authTicket)
    case let .masterPasswordChanged(masterKey, authTicket, newMasterPassword):
      state = .completed(
        Completion(
          masterKey: masterKey, authTicket: authTicket, newMasterPassword: newMasterPassword,
          isBackupCode: isBackupCode, verificationMethod: verificationMethod))
    case .getMasterKey(let recoveryKey, let authTicket):
      await masterKey(using: recoveryKey, authTicket: authTicket)
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
  }

  private mutating func start() async {
    switch loginType {
    case let .remote(authTicket):
      state = .recoveryKeyInput(authTicket)
    case let .deviceToDevice(deviceInfo):
      await makeVerificationMethod(login: login, deviceInfo: deviceInfo)
    case let .local(user, deviceInfo):
      if let authTicket = user.authTicket {
        state = .recoveryKeyInput(authTicket)
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

  private mutating func masterKey(
    using recoveryKey: String,
    authTicket: AuthTicket
  ) async {
    do {
      let masterKey = try await recoveryLoginService.masterKey(
        using: recoveryKey, authTicket: authTicket)
      await transition(with: .masterKeyReceived(masterKey, authTicket))
    } catch {
      state = .error(.init(underlyingError: Error.wrongRecoveryKey))
    }
  }
}
