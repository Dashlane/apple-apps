import Combine
import CoreKeychain
import CoreLocalization
import CoreSession
import CoreSettings
import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation
import StateMachine
import SwiftTreats
import UserTrackingFoundation

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
  @Published var isValidationInProgress: Bool = false
  @Published var shouldDisplayError: Bool = false
  @Published var showWrongPasswordError: Bool = false
  @Published var hasAccountRecoveryKey = false
  @Published var viewState: ViewState = .masterPassword

  let login: Login
  let completion: (CompletionType) -> Void
  var isExtension: Bool {
    context.localLoginContext.isExtension
  }

  var shouldSuggestMPReset: Bool = false
  let biometry: Biometry?

  let context: LoginUnlockContext

  @Published public var stateMachine: MasterPasswordLocalLoginStateMachine
  @Published public var isPerformingEvent: Bool = false

  private let recoveryKeyLoginFlowModelFactory: AccountRecoveryKeyLoginFlowModel.Factory
  private let forgotMasterPasswordSheetModelFactory: ForgotMasterPasswordSheetModel.Factory
  private let logger: Logger

  public init(
    login: Login,
    biometry: Biometry?,
    context: LoginUnlockContext,
    masterPasswordLocalStateMachine: MasterPasswordLocalLoginStateMachine,
    logger: Logger,
    recoveryKeyLoginFlowModelFactory: AccountRecoveryKeyLoginFlowModel.Factory,
    forgotMasterPasswordSheetModelFactory: ForgotMasterPasswordSheetModel.Factory,
    completion: @escaping (MasterPasswordLocalViewModel.CompletionType) -> Void
  ) {
    self.login = login
    self.context = context
    self.logger = logger
    self.completion = completion
    self.biometry = biometry
    self.recoveryKeyLoginFlowModelFactory = recoveryKeyLoginFlowModelFactory
    stateMachine = masterPasswordLocalStateMachine
    self.forgotMasterPasswordSheetModelFactory = forgotMasterPasswordSheetModelFactory
    if context.localLoginContext.isPasswordApp {
      Task {
        await self.perform(.initialize)
      }
    }
  }

  public func willPerform(_ event: MasterPasswordLocalLoginStateMachine.Event) async {
    switch event {
    case .validateMP:
      isValidationInProgress = true
      showWrongPasswordError = false
    case .initialize,
      .logout,
      .recoveryFinished,
      .cancelled,
      .initiateResetMP,
      .resetMP,
      .startAccountRecovery,
      .cancelAccountRecovery:
      break
    }
  }

  public func update(
    for event: MasterPasswordLocalLoginStateMachine.Event,
    from oldState: MasterPasswordLocalLoginStateMachine.State,
    to newState: MasterPasswordLocalLoginStateMachine.State
  ) async {
    switch (newState, event) {
    case (.initial, _):
      break
    case (let .validationSuccess(config), _):
      self.errorMessage = nil
      self.completion(.authenticated(config))
      self.isValidationInProgress = false

    case (let .validationFailed(error), _):
      self.attempts += 1
      switch error {
      case MasterPasswordLocalLoginStateMachine.Error.wrongMasterKey:
        self.showWrongPasswordError = true
      default:
        self.errorMessage = CoreL10n.errorMessage(for: error)
      }
      self.isValidationInProgress = false
    case (let .accountRecoveryFlow(state, loginType), _):
      self.viewState = .accountRecovery(state, loginType)
    case (.accountRecoveryCancelled, _):
      self.viewState = .masterPassword
    case (let .waitingForUserInput(isARKEnabled, isResetMPActive), _):
      hasAccountRecoveryKey = isARKEnabled
      shouldSuggestMPReset = isResetMPActive
    case (.resetMPinProgress, _):
      await self.perform(.resetMP)
    case (.cancelled, _), (.logout, _):
      self.completion(.cancel)
    }
  }

  func validate() async throws {
    await self.perform(.validateMP(password, newMasterPassword: nil))
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
    #if DEBUG
      if !ProcessInfo.isTesting {
        guard password.isEmpty else { return }
        password = TestAccount.password
      }
    #endif
  }

  func makeForgotMasterPasswordSheetModel() -> ForgotMasterPasswordSheetModel {
    forgotMasterPasswordSheetModelFactory.make(
      login: login.email,
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
      stateMachine: stateMachine.makeAccountRecoveryKeyLoginFlowStateMachine(loginType: loginType),
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

extension MasterPasswordLocalViewModel {
  public static var mock: MasterPasswordLocalViewModel {
    MasterPasswordLocalViewModel(
      login: Login("_"),
      biometry: nil,
      context: LoginUnlockContext(
        verificationMode: .emailToken,
        origin: .login,
        localLoginContext: .passwordApp
      ),
      masterPasswordLocalStateMachine: .mock,
      logger: .mock,
      recoveryKeyLoginFlowModelFactory: .init({ _, _, _ in .mock }),
      forgotMasterPasswordSheetModelFactory: .init({ login, hasMasterPasswordReset, _, _ in
        .init(login: login, activityReporter: .mock, hasMasterPasswordReset: hasMasterPasswordReset)
      }),
      completion: { _ in }
    )
  }
}
