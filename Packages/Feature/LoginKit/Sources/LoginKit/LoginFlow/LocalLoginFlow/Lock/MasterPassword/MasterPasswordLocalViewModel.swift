import Combine
import CoreKeychain
import CoreLocalization
import CoreSession
import CoreSettings
import CoreUserTracking
import DashTypes
import DashlaneAPI
import Foundation
import StateMachine
import SwiftTreats

@MainActor
public final class MasterPasswordLocalViewModel: StateMachineBasedObservableObject,
  LoginKitServicesInjecting
{

  public enum CompletionType {
    case authenticated(LocalLoginConfiguration)
    case biometry(Biometry)
    case cancel
  }

  enum ViewState: Equatable {
    case masterPassword
    case accountRecovery(
      AccountRecoveryKeyLoginFlowStateMachine.State,
      AccountRecoveryKeyLoginFlowStateMachine.LoginType)
  }

  @Published var attempts: Int = 0
  @Published var password: String = "" {
    didSet {
      guard password != oldValue else { return }
      errorMessage = nil
      showWrongPasswordError = false
    }
  }
  @Published var errorMessage: String?
  @Published var inProgress: Bool = false
  @Published var shouldDisplayError: Bool = false
  @Published var showWrongPasswordError: Bool = false
  @Published var hasAccountRecoveryKey = false
  @Published var viewState: ViewState = .masterPassword

  let login: Login
  let completion: (CompletionType) -> Void
  var isExtension: Bool {
    context.localLoginContext.isExtension
  }

  let shouldSuggestMPReset: Bool
  let biometry: Biometry?
  let activityReporter: ActivityReporterProtocol

  let context: LoginUnlockContext

  public var stateMachine: MasterPasswordLocalLoginStateMachine

  private let loginMetricsReporter: LoginMetricsReporterProtocol
  private let pinCodeAttempts: PinCodeAttempts
  private let recoveryKeyLoginFlowModelFactory: AccountRecoveryKeyLoginFlowModel.Factory
  private let logger: Logger

  public init(
    login: Login,
    biometry: Biometry?,
    user: AccountRecoveryKeyLoginFlowStateMachine.User,
    unlocker: UnlockSessionHandler,
    context: LoginUnlockContext,
    resetMasterPasswordService: ResetMasterPasswordServiceProtocol,
    loginMetricsReporter: LoginMetricsReporterProtocol,
    activityReporter: ActivityReporterProtocol,
    userSettings: UserSettings,
    logger: Logger,
    recoveryKeyLoginFlowModelFactory: AccountRecoveryKeyLoginFlowModel.Factory,
    masterPasswordLocalStateMachineFactory: MasterPasswordLocalLoginStateMachine.Factory,
    completion: @escaping (MasterPasswordLocalViewModel.CompletionType) -> Void
  ) {
    self.login = login
    self.context = context
    self.loginMetricsReporter = loginMetricsReporter
    self.logger = logger
    self.pinCodeAttempts = .init(internalStore: userSettings.internalStore)
    self.completion = completion
    self.biometry = biometry
    shouldSuggestMPReset =
      context.localLoginContext.isPasswordApp ? resetMasterPasswordService.isActive : false
    self.activityReporter = activityReporter
    self.recoveryKeyLoginFlowModelFactory = recoveryKeyLoginFlowModelFactory
    stateMachine = masterPasswordLocalStateMachineFactory.make(
      login: login, unlocker: unlocker, resetMasterPasswordService: resetMasterPasswordService,
      loginType: .local(user, DeviceInfo.default))
    if context.localLoginContext.isPasswordApp {
      Task {
        await self.perform(.fetchAccountRecoveryKeyStatus)
      }
    }
  }

  public func update(
    for event: MasterPasswordLocalLoginStateMachine.Event,
    from oldState: MasterPasswordLocalLoginStateMachine.State,
    to newState: MasterPasswordLocalLoginStateMachine.State
  ) {
    switch (newState, event) {
    case (let .validationSuccess(config), _):
      self.errorMessage = nil
      self.pinCodeAttempts.removeAll()
      self.inProgress = false
      self.completion(.authenticated(config))
    case (let .validationFailed(error), _):
      self.loginMetricsReporter.resetTimer(.login)
      self.inProgress = false
      self.attempts += 1
      switch error {
      case MasterPasswordLocalLoginStateMachine.Error.wrongMasterKey:
        self.showWrongPasswordError = true
        self.activityReporter.logLoginStatus(.errorWrongPassword, context: context)
      default:
        self.errorMessage = L10n.errorMessage(for: error)
        self.activityReporter.logLoginStatus(.errorUnknown, context: context)
      }
    case (let .accountRecoveryFlow(state, loginType), _):
      self.viewState = .accountRecovery(state, loginType)
    case (.accountRecoveryCancelled, _):
      self.viewState = .masterPassword
    case (let .waitingForUserInput(enabled), _):
      hasAccountRecoveryKey = enabled
    case (.validationInProgress, _):
      self.showWrongPasswordError = false
      self.inProgress = true
      loginMetricsReporter.startLoginTimer(from: .masterPassword)
      Task {
        await self.perform(.validateMP(password, newMasterPassword: nil))
      }
    case (.resetMPinProgress, _):
      self.inProgress = true
      activityReporter.logForgotPassword(shouldSuggestMPReset: shouldSuggestMPReset)
      loginMetricsReporter.startLoginTimer(from: .masterPassword)
      Task {
        await self.perform(.resetMP)
      }
    case (.cancelled, _), (.logout, _):
      self.completion(.cancel)
    }
  }

  func validate() async throws {
    await self.perform(.initiateMPvalidation)
  }

  public func didTapResetMP() async {
    await self.perform(.initiateResetMP)
  }

  func showBiometryView() {
    guard let biometry = biometry else {
      return
    }
    completion(.biometry(biometry))
  }

  func onViewAppear() {
    logOnAppear()
    #if DEBUG
      if !ProcessInfo.isTesting {
        guard password.isEmpty else { return }
        password = TestAccount.password
      }
    #endif
  }

  private func logOnAppear() {
    activityReporter.logOnAppear(for: context)
  }

  func makeForgotMasterPasswordSheetModel() -> ForgotMasterPasswordSheetModel {
    ForgotMasterPasswordSheetModel(
      login: login.email,
      activityReporter: activityReporter,
      hasMasterPasswordReset: shouldSuggestMPReset,
      didTapResetMP: { [weak self] in
        Task {
          await self?.didTapResetMP()
        }
      },
      didTapAccountRecovery: { [weak self] in
        Task {
          await self?.perform(.startAccountRecovery)
        }
      }
    )
  }

  func makeAccountRecoveryFlowModel(
    state: AccountRecoveryKeyLoginFlowStateMachine.State,
    loginType: AccountRecoveryKeyLoginFlowStateMachine.LoginType
  ) -> AccountRecoveryKeyLoginFlowModel {
    recoveryKeyLoginFlowModelFactory.make(
      login: login,
      accountType: .masterPassword,
      loginType: loginType,
      completion: { [weak self] result in
        guard let self = self else {
          return
        }
        switch result {
        case .cancel:
          Task {
            await self.perform(.cancelAccountRecovery)
          }
        case let .completed(result):
          Task {
            await self.perform(.recoveryFinished(result))
          }
        }
      }
    )
  }
}

extension ActivityReporterProtocol {
  fileprivate func logLoginStatus(_ status: Definition.Status, context: LoginUnlockContext) {
    report(
      UserEvent.Login(
        isBackupCode: context.isBackupCode,
        mode: .masterPassword,
        status: status,
        verificationMode: context.verificationMode
      )
    )
  }

  fileprivate func logOnAppear(for context: LoginUnlockContext) {
    if context.verificationMode == .none {
      report(
        UserEvent.AskAuthentication(
          mode: .masterPassword,
          reason: context.reason,
          verificationMode: context.verificationMode
        )
      )
    }
    reportPageShown(.unlockMp)
  }

  fileprivate func logForgotPassword(shouldSuggestMPReset: Bool) {
    let shouldSuggestMPReset = shouldSuggestMPReset
    report(
      UserEvent.ForgetMasterPassword(
        hasBiometricReset: shouldSuggestMPReset,
        hasTeamAccountRecovery: false
      )
    )
  }
}

extension MasterPasswordLocalViewModel {
  public static var mock: MasterPasswordLocalViewModel {
    MasterPasswordLocalViewModel(
      login: Login("_"),
      biometry: nil,
      user: .normalUser,
      unlocker: .mock(),
      context: LoginUnlockContext(
        verificationMode: .emailToken,
        isBackupCode: nil,
        origin: .login,
        localLoginContext: .passwordApp
      ),
      resetMasterPasswordService: ResetMasterPasswordService.mock,
      loginMetricsReporter: .fake,
      activityReporter: .mock,
      userSettings: .mock,
      logger: .mock,
      recoveryKeyLoginFlowModelFactory: .init({ _, _, _, _ in .mock }),
      masterPasswordLocalStateMachineFactory: .init({
        _, unlocker, resetMasterPasswordService, loginType in
        .init(
          login: Login(""), unlocker: unlocker, appAPIClient: .mock({}),
          resetMasterPasswordService: resetMasterPasswordService, loginType: loginType,
          logger: .mock)
      }),
      completion: { _ in }
    )
  }
}
