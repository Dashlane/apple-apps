import Combine
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
public final class MasterPasswordInputRemoteViewModel: LoginKitServicesInjecting,
  StateMachineBasedObservableObject
{

  let login: Login

  @Published
  var attempts: Int = 0

  @Published
  var password: String = "" {
    didSet {
      guard password != oldValue else { return }
      errorMessage = nil
      showWrongPasswordError = false
    }
  }

  @Published
  var errorMessage: String?

  @Published
  var inProgress: Bool = false

  @Published
  var isAccountRecoveryEnabled: Bool = false

  @Published
  var showWrongPasswordError: Bool = false

  @Published
  var showRecoveryProgress: Bool = false

  @Published
  var recoveryProgressState: ProgressionState = .inProgress("")

  enum ViewState: Hashable {
    case masterPassword
    case accountRecovery(AuthTicket)
  }

  @Published
  var viewState: ViewState

  public var stateMachine: MasterPasswordRemoteStateMachine
  let loginMetricsReporter: LoginMetricsReporterProtocol
  let completion: (RemoteLoginSession) -> Void
  let logger: Logger
  let activityReporter: ActivityReporterProtocol
  private let recoveryKeyLoginFlowModelFactory: AccountRecoveryKeyLoginFlowModel.Factory

  public init(
    state: MasterPasswordRemoteStateMachine.State,
    login: Login,
    loginMetricsReporter: LoginMetricsReporterProtocol,
    activityReporter: ActivityReporterProtocol,
    data: DeviceRegistrationData,
    logger: Logger,
    recoveryKeyLoginFlowModelFactory: AccountRecoveryKeyLoginFlowModel.Factory,
    masterPasswordRemoteStateMachineFactory: MasterPasswordRemoteStateMachine.Factory,
    completion: @escaping (RemoteLoginSession) -> Void
  ) {
    self.login = login
    self.loginMetricsReporter = loginMetricsReporter
    self.stateMachine = masterPasswordRemoteStateMachineFactory.make(
      state: state, login: login, data: data)
    self.logger = logger
    self.completion = completion
    self.activityReporter = activityReporter
    self.recoveryKeyLoginFlowModelFactory = recoveryKeyLoginFlowModelFactory
    self.viewState = .masterPassword
    Task {
      await perform(.fetchAccountRecoveryKeyStatus)
    }
  }

  public func update(
    for event: CoreSession.MasterPasswordRemoteStateMachine.Event,
    from oldState: MasterPasswordRemoteStateMachine.State,
    to newState: MasterPasswordRemoteStateMachine.State
  ) async {
    switch (state, event) {
    case (let .completed(remoteLoginSession), .accountRecoveryDidFinish):
      self.viewState = .masterPassword
      self.completion(remoteLoginSession)
    case (let .completed(remoteLoginSession), _):
      self.completion(remoteLoginSession)
    case (let .waitingForUserInput(isAccountRecoveryEnabled), _):
      self.isAccountRecoveryEnabled = isAccountRecoveryEnabled
    case (let .accountRecovery(authTicket), _):
      self.viewState = .accountRecovery(authTicket)
    case (.failed, let .accountRecoveryDidFinish(data)):
      self.viewState = .masterPassword
      self.errorMessage = CoreLocalization.L10n.errorMessage(
        for: RemoteLoginStateMachine.Error.wrongMasterKey)
      self.logLoginStatus(
        .errorUnknown, isBackupCode: data.isBackupCode, verificationMethod: data.verificationMethod)
    case (let .failed(error, isBackupCode, verificationMethod), _):
      self.inProgress = false
      self.loginMetricsReporter.resetTimer(.login)
      self.attempts += 1
      switch error.underlyingError {
      case RemoteLoginStateMachine.Error.wrongMasterKey:
        self.showWrongPasswordError = true
        self.logLoginStatus(
          .errorWrongPassword, isBackupCode: isBackupCode, verificationMethod: verificationMethod)
      default:
        self.errorMessage = CoreLocalization.L10n.errorMessage(for: error)
        self.logLoginStatus(
          .errorUnknown, isBackupCode: isBackupCode, verificationMethod: verificationMethod)
      }
    case (.accountRecoveryCancelled, _):
      self.viewState = .masterPassword
    }
  }

  public func validate() async {
    self.showWrongPasswordError = false
    inProgress = true
    loginMetricsReporter.startLoginTimer(from: .masterPassword)
    await self.perform(.validateMasterPassword(password))
  }

  public func logLoginStatus(
    _ status: Definition.Status, isBackupCode: Bool, verificationMethod: VerificationMethod
  ) {

    activityReporter.report(
      UserEvent.Login(
        isBackupCode: isBackupCode,
        mode: .masterPassword,
        status: status,
        verificationMode: verificationMethod.verificationMode
      )
    )
  }

  func onViewAppear() {
    activityReporter.reportPageShown(.unlockMp)

    #if DEBUG
      if !ProcessInfo.isTesting {
        guard password.isEmpty else { return }
        password = TestAccount.password
      }
    #endif
  }

  private func logOnAppear() {
    activityReporter.reportPageShown(.unlockMp)
  }
}

extension MasterPasswordInputRemoteViewModel {
  func makeForgotMasterPasswordSheetModel() -> ForgotMasterPasswordSheetModel {
    ForgotMasterPasswordSheetModel(
      login: login.email,
      activityReporter: activityReporter,
      hasMasterPasswordReset: false,
      didTapAccountRecovery: { [weak self] in
        Task {
          await self?.perform(.startAccountRecovery)
        }
      }
    )
  }

  func makeAccountRecoveryFlowModel(authTicket: AuthTicket) -> AccountRecoveryKeyLoginFlowModel {
    return recoveryKeyLoginFlowModelFactory.make(
      login: login,
      accountType: .masterPassword,
      loginType: .remote(authTicket),
      completion: { [weak self] result in
        guard let self = self else {
          return
        }

        switch result {
        case let .completed(data):
          self.showRecoveryProgress = true
          Task {
            await self.perform(.accountRecoveryDidFinish(data))
          }
        case .cancel:
          Task {
            await self.perform(.cancelAccountRecovery)
          }
        }
      }
    )
  }
}

extension MasterPasswordInputRemoteViewModel {
  static var mock: MasterPasswordInputRemoteViewModel {
    MasterPasswordInputRemoteViewModel(
      state: .waitingForUserInput(false),
      login: Login("_"),
      loginMetricsReporter: .fake,
      activityReporter: .mock,
      data: .mock,
      logger: LoggerMock(),
      recoveryKeyLoginFlowModelFactory: .init { _, _, _, _ in .mock },
      masterPasswordRemoteStateMachineFactory: .init { _, _, _ in
        .mock
      },
      completion: { _ in
      }
    )
  }
}
