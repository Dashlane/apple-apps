import Foundation
import LoginKit
import CoreLocalization
import CoreUserTracking

@MainActor
class AccountRecoveryConfirmationViewModel: ObservableObject {
    let recoveryKey: String

    @Published
    var userRecoveryKey: String {
        didSet {
            showNoMatchError = false
        }
    }

    @Published
    var showNoMatchError = false

    @Published
    var progressState: ProgressionState = .inProgress("")

    @Published
    var inProgress = false

    private let accountRecoveryKeyService: AccountRecoveryKeyService
    private let completion: () -> Void
    private let activityReporter: ActivityReporterProtocol

    init(recoveryKey: String,
         showNoMatchError: Bool = false,
         userRecoveryKey: String = "",
         accountRecoveryKeyService: AccountRecoveryKeyService,
         activityReporter: ActivityReporterProtocol,
         completion: @escaping () -> Void) {
        self.recoveryKey = recoveryKey
        self.userRecoveryKey = userRecoveryKey
        self.showNoMatchError = showNoMatchError
        self.accountRecoveryKeyService = accountRecoveryKeyService
        self.activityReporter = activityReporter
        self.completion = completion
    }

    func activate() async {
        guard recoveryKey == userRecoveryKey.replacingOccurrences(of: "-", with: "") else {
            showNoMatchError = true
            return
        }
        do {
            inProgress = true
            try await accountRecoveryKeyService.activateAccountRecoveryKey(recoveryKey)
            progressState = .completed(L10n.Localizable.recoveryKeyActivationSuccessMessage, completion)
            activityReporter.report(UserEvent.CreateAccountRecoveryKey(flowStep: .complete))
        } catch {
            progressState = .failed(CoreLocalization.L10n.Core.recoveryKeyActivationFailureMessage, completion)
            activityReporter.report(UserEvent.CreateAccountRecoveryKey(flowStep: .error))
        }
    }
}
