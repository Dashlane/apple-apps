import Combine
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

  @Published public var stateMachine: MasterPasswordInputRemoteStateMachine
  @Published public var isPerformingEvent: Bool = false

  let completion: (RemoteLoginSession) -> Void
  let logger: Logger
  let activityReporter: ActivityReporterProtocol
  private let recoveryKeyLoginFlowModelFactory: AccountRecoveryKeyLoginFlowModel.Factory

  public init(
    stateMachine: MasterPasswordInputRemoteStateMachine,
    login: Login,
    activityReporter: ActivityReporterProtocol,
    data: DeviceRegistrationData,
    logger: Logger,
    recoveryKeyLoginFlowModelFactory: AccountRecoveryKeyLoginFlowModel.Factory,
    completion: @escaping (RemoteLoginSession) -> Void
  ) {
    self.login = login
    self.stateMachine = stateMachine
    self.logger = logger
    self.completion = completion
    self.activityReporter = activityReporter
    self.recoveryKeyLoginFlowModelFactory = recoveryKeyLoginFlowModelFactory
    self.viewState = .masterPassword
    Task {
      await perform(.fetchAccountRecoveryKeyStatus)
    }
  }

  public func willPerform(_ event: MasterPasswordInputRemoteStateMachine.Event) async {
    switch event {
    case .validateMasterPassword:
      inProgress = true
      showWrongPasswordError = false

    case .fetchAccountRecoveryKeyStatus, .startAccountRecovery, .accountRecoveryDidFinish,
      .cancelAccountRecovery:
      break
    }
  }

  public func update(
    for event: CoreSession.MasterPasswordInputRemoteStateMachine.Event,
    from oldState: MasterPasswordInputRemoteStateMachine.State,
    to newState: MasterPasswordInputRemoteStateMachine.State
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
      self.errorMessage = CoreL10n.errorMessage(for: RemoteLoginStateMachine.Error.wrongMasterKey)
      self.logLoginStatus(
        .errorUnknown, isBackupCode: data.isBackupCode, verificationMethod: data.verificationMethod)
    case (let .failed(error, isBackupCode, verificationMethod), _):
      self.inProgress = false
      self.attempts += 1
      switch error.underlyingError {
      case RemoteLoginStateMachine.Error.wrongMasterKey:
        self.showWrongPasswordError = true
        self.logLoginStatus(
          .errorWrongPassword, isBackupCode: isBackupCode, verificationMethod: verificationMethod)
      default:
        self.errorMessage = CoreL10n.errorMessage(for: error.underlyingError)
        self.logLoginStatus(
          .errorUnknown, isBackupCode: isBackupCode, verificationMethod: verificationMethod)
      }
    case (.accountRecoveryCancelled, _):
      self.viewState = .masterPassword
    }
  }

  public func validate() async {
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
      stateMachine: stateMachine.makeAccountRecoveryKeyLoginFlowStateMachine(
        loginType: .remote(authTicket)),
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
      stateMachine: .mock,
      login: Login("_"),
      activityReporter: .mock,
      data: .mock,
      logger: .mock,
      recoveryKeyLoginFlowModelFactory: .init { _, _, _ in .mock },
      completion: { _ in
      }
    )
  }
}
