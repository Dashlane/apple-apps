import CoreNetworking
import DashTypes
import DashlaneAPI
import StateMachine

public struct AccountRecoveryKeyLoginFlowStateMachine: StateMachine {

  public enum LoginType {
    case remote(AuthTicket)
    case deviceToDevice(DeviceInfo)
    case local(_ authTicket: AuthTicket?, DeviceInfo)
  }

  public enum State: Hashable {
    case loading
    case error
    case accountVerification(VerificationMethod, DeviceInfo)
    case recoveryKeyInput(AuthTicket)
    case masterPasswordChangeNeeded(MasterKey, AuthTicket)
    case completed(MasterKey, AuthTicket)
    case completedWithChangedMP(MasterKey, AuthTicket, newMasterPassword: String)
    case cancel
  }

  public enum Event {
    case start
    case errorEncountered
    case accountVerified(AuthTicket)
    case masterPasswordChanged(MasterKey, AuthTicket, newMasterPassword: String)
    case getMasterKey(recoveryKey: String, AuthTicket)
    case masterKeyReceived(MasterKey, AuthTicket)
    case cancel
  }

  public private(set) var state: State = .loading

  private let login: Login
  private let loginType: LoginType
  private let accountType: AccountType
  private let appAPIClient: AppAPIClient
  private let recoveryLoginService: AccountRecoveryKeyLoginService

  public init(
    login: Login,
    loginType: LoginType,
    accountType: AccountType,
    appAPIClient: AppAPIClient,
    cryptoEngineProvider: CryptoEngineProvider
  ) {
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
    case .errorEncountered:
      state = .error
    case .accountVerified(let authTicket):
      state = .recoveryKeyInput(authTicket)
    case .masterPasswordChanged(let masterKey, let authTicket, let newMasterPassword):
      state = .completedWithChangedMP(masterKey, authTicket, newMasterPassword: newMasterPassword)
    case .getMasterKey(let recoveryKey, let authTicket):
      await masterKey(using: recoveryKey, authTicket: authTicket)
    case .masterKeyReceived(let masterKey, let authTicket):
      if case .masterPassword = accountType {
        state = .masterPasswordChangeNeeded(masterKey, authTicket)
      } else {
        state = .completed(masterKey, authTicket)
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
    case let .local(authTicket, deviceInfo):
      if let authTicket = authTicket {
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
      state = .error
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
      state = .error
    }
  }
}
