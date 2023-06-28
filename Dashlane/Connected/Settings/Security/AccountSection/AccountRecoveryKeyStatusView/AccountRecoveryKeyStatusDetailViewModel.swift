import Foundation
import DashTypes
import DashlaneAPI
import CorePersonalData
import CoreSession
import CoreUserTracking

@MainActor
public class AccountRecoveryKeyStatusDetailViewModel: ObservableObject, SessionServicesInjecting {
    @Published
    var isEnabled: Bool

    @Published
    var inProgress: Bool = false

    @Published
    var presentedSheet: Sheet?

    private let accountRecoveryKeyService: AccountRecoveryKeyService
    private let logger: Logger
    private let session: Session
    private let accountRecoveryActivationFlowModelFactory: AccountRecoveryActivationFlowModel.Factory
    private let activityReporter: ActivityReporterProtocol
    public var authenticationMethod: AuthenticationMethod {
        session.authenticationMethod
    }

    enum Sheet: String, Identifiable {
        var id: String {
            rawValue
        }

        case activation
        case error
    }

    init(isEnabled: Bool,
         session: Session,
         accountRecoveryKeyService: AccountRecoveryKeyService,
         accountRecoveryActivationFlowModelFactory: AccountRecoveryActivationFlowModel.Factory,
         activityReporter: ActivityReporterProtocol,
         logger: Logger) {
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
                activityReporter.report(UserEvent.DeleteAccountRecoveryKey(deleteKeyReason: .settingDisabled))
            } catch {
                presentedSheet = .error
            }
        }
    }

    func fetchStatus() {
        inProgress = true
        Task {
            isEnabled = try await accountRecoveryKeyService.fetchKeyStatus()
            inProgress = false
        }
    }
}

extension AccountRecoveryKeyStatusDetailViewModel {
    static var mock: AccountRecoveryKeyStatusDetailViewModel {
        AccountRecoveryKeyStatusDetailViewModel(isEnabled: false, session: Session.mock, accountRecoveryKeyService: .mock, accountRecoveryActivationFlowModelFactory: .init({ _ in .mock}), activityReporter: .fake, logger: LoggerMock())
    }
}
