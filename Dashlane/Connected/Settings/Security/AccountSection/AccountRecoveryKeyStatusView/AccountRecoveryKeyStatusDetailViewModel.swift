import CorePersonalData
import CoreSession
import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation
import UserTrackingFoundation

@MainActor
public class AccountRecoveryKeyStatusDetailViewModel: ObservableObject, SessionServicesInjecting {
  @Published
  var isEnabled: Bool

  @Published
  var presentedSheet: Sheet?

  private let accountRecoveryKeyService: AccountRecoveryKeySetupService
  private let logger: Logger
  private let session: Session
  private let accountRecoveryActivationFlowModelFactory: AccountRecoveryActivationFlowModel.Factory
  private let activityReporter: ActivityReporterProtocol
  public var authenticationMethod: AuthenticationMethod {
    session.authenticationMethod
  }

  var footerLabel: String {
    return session.configuration.info.accountType == .invisibleMasterPassword
      ? L10n.Localizable.recoveryKeySettingsFooterMpless
      : L10n.Localizable.recoveryKeySettingsFooter
  }

  enum Sheet: String, Identifiable {
    var id: String {
      rawValue
    }

    case activation
    case error
  }

  init(
    isEnabled: Bool,
    session: Session,
    accountRecoveryKeyService: AccountRecoveryKeySetupService,
    accountRecoveryActivationFlowModelFactory: AccountRecoveryActivationFlowModel.Factory,
    activityReporter: ActivityReporterProtocol,
    logger: Logger
  ) {
    self.isEnabled = isEnabled
    self.session = session
    self.accountRecoveryKeyService = accountRecoveryKeyService
    self.accountRecoveryActivationFlowModelFactory = accountRecoveryActivationFlowModelFactory
    self.logger = logger
    self.activityReporter = activityReporter
  }

  func makeAccountRecoveryActivationFlowModel() -> AccountRecoveryActivationFlowModel {
    accountRecoveryActivationFlowModelFactory.make(context: .settings)
  }

  func deactivate() {
    Task {
      do {
        try await accountRecoveryKeyService.deactivateAccountRecoveryKey(for: .settings)
        activityReporter.report(
          UserEvent.DeleteAccountRecoveryKey(deleteKeyReason: .settingDisabled))
        isEnabled = false
      } catch {
        presentedSheet = .error
      }
    }
  }

  func fetchStatus() {
    Task {
      isEnabled = try await accountRecoveryKeyService.fetchKeyStatus()
    }
  }
}

extension AccountRecoveryKeyStatusDetailViewModel {
  static var mock: AccountRecoveryKeyStatusDetailViewModel {
    AccountRecoveryKeyStatusDetailViewModel(
      isEnabled: false, session: Session.mock, accountRecoveryKeyService: .mock,
      accountRecoveryActivationFlowModelFactory: .init({ _ in .mock }), activityReporter: .mock,
      logger: .mock)
  }
}
