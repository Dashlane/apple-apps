import CorePasswords
import CoreSession
import CoreUserTracking
import DashTypes
import DashlaneAPI
import Foundation
import StateMachine

@MainActor
public final class AccountRecoveryKeyLoginFlowModel: StateMachineBasedObservableObject,
  LoginKitServicesInjecting
{

  public enum Completion {
    case completed(AccountRecoveryKeyLoginFlowStateMachine.Completion)
    case cancel
  }

  enum Step {
    case verification(VerificationMethod, DeviceInfo)
    case recoveryKeyInput(_ authTicket: AuthTicket)
    case changeMasterPassword(CoreSession.MasterKey, AuthTicket)
  }

  @Published var steps: [Step] = []
  @Published var inProgress = false
  @Published var showError = false
  @Published var showNoMatchError: Bool = false

  private let login: Login
  private let accountType: CoreSession.AccountType

  public var stateMachine: AccountRecoveryKeyLoginFlowStateMachine

  private let passwordEvaluator: PasswordEvaluatorProtocol
  private let activityReporter: ActivityReporterProtocol

  private let accountVerificationFlowModelFactory: AccountVerificationFlowModel.Factory
  private let accountRecoveryKeyLoginViewModelFactory: AccountRecoveryKeyLoginViewModel.Factory
  private let newMasterPasswordViewModelFactory: NewMasterPasswordViewModel.Factory

  private let completion: @MainActor (Completion) -> Void

  public init(
    login: Login,
    accountType: CoreSession.AccountType,
    loginType: AccountRecoveryKeyLoginFlowStateMachine.LoginType,
    appAPIClient: AppAPIClient,
    cryptoEngineProvider: CryptoEngineProvider,
    passwordEvaluator: PasswordEvaluatorProtocol,
    activityReporter: ActivityReporterProtocol,
    accountVerificationFlowModelFactory: AccountVerificationFlowModel.Factory,
    accountRecoveryKeyLoginViewModelFactory: AccountRecoveryKeyLoginViewModel.Factory,
    newMasterPasswordViewModelFactory: NewMasterPasswordViewModel.Factory,
    completion: @escaping @MainActor (AccountRecoveryKeyLoginFlowModel.Completion) -> Void
  ) {
    self.login = login
    self.accountType = accountType
    self.completion = completion
    self.passwordEvaluator = passwordEvaluator
    self.activityReporter = activityReporter
    self.accountVerificationFlowModelFactory = accountVerificationFlowModelFactory
    self.accountRecoveryKeyLoginViewModelFactory = accountRecoveryKeyLoginViewModelFactory
    self.newMasterPasswordViewModelFactory = newMasterPasswordViewModelFactory
    self.stateMachine = .init(
      initialState: .loading,
      login: login,
      loginType: loginType,
      accountType: accountType,
      appAPIClient: appAPIClient,
      cryptoEngineProvider: cryptoEngineProvider
    )

    start(login: login)
  }

  func start(login: Login) {
    logFlowStep(.start)
    Task {
      await perform(.start)
    }
  }

  func cancel() {
    logFlowStep(.cancel)
    completion(.cancel)
  }

  func makeAccountVerificationFlowViewModel(
    method: VerificationMethod,
    deviceInfo: DeviceInfo
  ) -> AccountVerificationFlowModel {
    accountVerificationFlowModelFactory.make(
      login: login,
      mode: .masterPassword,
      verificationMethod: method,
      deviceInfo: deviceInfo
    ) { [weak self] completion in
      self?.handleAccountVerificationFlowViewModelCompletion(completion, verificationMethod: method)
    }
  }

  func makeAccountRecoveryKeyLoginViewModel(authTicket: AuthTicket)
    -> AccountRecoveryKeyLoginViewModel
  {
    accountRecoveryKeyLoginViewModelFactory.make(accountType: accountType) {
      [weak self] recoveryKey in
      await self?.perform(.getMasterKey(recoveryKey: recoveryKey, authTicket))
    }
  }

  func makeNewMasterPasswordViewModel(masterKey: CoreSession.MasterKey, authTicket: AuthTicket)
    -> NewMasterPasswordViewModel
  {
    newMasterPasswordViewModelFactory.make(mode: .masterPasswordChange) { [weak self] completion in
      self?.handleNewMasterPasswordViewModelCompletion(completion, masterKey, authTicket)
    }
  }
}

extension AccountRecoveryKeyLoginFlowModel {
  public func update(
    for event: AccountRecoveryKeyLoginFlowStateMachine.Event,
    from oldState: AccountRecoveryKeyLoginFlowStateMachine.State,
    to newState: AccountRecoveryKeyLoginFlowStateMachine.State
  ) {
    defer {
      if newState != .loading, inProgress {
        inProgress = false
      }
    }

    switch newState {
    case .loading:
      inProgress = true
    case let .error(error)
    where error.underlyingError as? AccountRecoveryKeyLoginFlowStateMachine.Error
      == AccountRecoveryKeyLoginFlowStateMachine.Error.wrongRecoveryKey:
      logFlowStep(.error)
      showNoMatchError = true
    case .error:
      logFlowStep(.error)
      showError = true
    case .accountVerification(let verificationMethod, let deviceInfo):
      steps.append(.verification(verificationMethod, deviceInfo))
    case .recoveryKeyInput(let authTicket):
      steps.append(.recoveryKeyInput(authTicket))
    case .masterPasswordChangeNeeded(let masterKey, let authTicket):
      steps.append(.changeMasterPassword(masterKey, authTicket))
    case let .completed(result):
      completion(.completed(result))
    case .cancel:
      cancel()
    }
  }
}

extension AccountRecoveryKeyLoginFlowModel {
  fileprivate func handleNewMasterPasswordViewModelCompletion(
    _ completion: NewMasterPasswordViewModel.Completion,
    _ masterKey: CoreSession.MasterKey,
    _ authTicket: AuthTicket
  ) {
    switch completion {
    case .back:
      _ = steps.popLast()
    case let .next(masterPassword):
      Task {
        await perform(
          .masterPasswordChanged(masterKey, authTicket, newMasterPassword: masterPassword))
      }
    }
  }

  fileprivate func handleAccountVerificationFlowViewModelCompletion(
    _ completion: Result<(AuthTicket, Bool), Error>, verificationMethod: VerificationMethod
  ) {
    Task {
      do {
        let (authTicket, isBackupCode) = try completion.get()
        await self.perform(
          .accountVerified(authTicket, isBackupCode: isBackupCode, verificationMethod))
      } catch {
        await self.perform(.errorEncountered(StateMachineError(underlyingError: error)))
      }
    }
  }
}

extension AccountRecoveryKeyLoginFlowModel {
  static var mock: AccountRecoveryKeyLoginFlowModel {
    AccountRecoveryKeyLoginFlowModel(
      login: "_",
      accountType: .invisibleMasterPassword,
      loginType: .local(.otp2User(AuthTicket(value: "authTicket")), .mock),
      appAPIClient: .fake,
      cryptoEngineProvider: SessionCryptoEngineProvider(logger: LoggerMock.mock),
      passwordEvaluator: PasswordEvaluatorMock.mock(),
      activityReporter: .mock,
      accountVerificationFlowModelFactory: .init { _, _, _, _, _, _ in
        .mock(verificationMethod: .emailToken)
      },
      accountRecoveryKeyLoginViewModelFactory: .init { _, _ in .mock() },
      newMasterPasswordViewModelFactory: .init { _, _, _, _, _ in .mock(mode: .masterPasswordChange)
      },
      completion: { _ in }
    )
  }
}

extension AccountRecoveryKeyLoginFlowModel {
  func logFlowStep(_ step: Definition.FlowStep) {
    activityReporter.report(UserEvent.UseAccountRecoveryKey(flowStep: step))
  }
}
