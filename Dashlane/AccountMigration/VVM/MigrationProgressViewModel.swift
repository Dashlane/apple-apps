import Foundation
import CoreSession
import CorePersonalData
import CoreUserTracking
import DashlaneAppKit
import SwiftTreats

class MigrationProgressViewModel: ObservableObject {
    struct MigrationAlert: Identifiable {
        enum Reason: String, Hashable {
            case masterPasswordSuccess 
            case failure
        }

        let reason: Reason
        let dismissAction: () -> Void

        var id: Reason {
            return reason
        }
    }

    @Published
    var isProgress: Bool

    @Published
    var isSuccess: Bool

    @Published
    var progressionText: String = L10n.Localizable.accountMigrationProgressDownLoading

    @Published
    var currentAlert: MigrationAlert?

    let completion: (Result<Session, Error>) -> Void
    let type: MigrationType
    let activityReporter: ActivityReporterProtocol

    init(type: MigrationType,
         activityReporter: ActivityReporterProtocol,
         isProgress: Bool = true,
         isSuccess: Bool = true,
         completion: @escaping (Result<Session, Error>) -> Void) {
        self.type = type
        self.completion = completion
        self.isProgress = isProgress
        self.isSuccess = isSuccess
        self.activityReporter = activityReporter
    }

    private func didComplete(_ session: Session) {
        logChangeMasterPasswordStep(.complete)

        self.completion(.success(session))
    }

    private func didFail(_ error: AccountCryptoChangerError) {
        logChangeMasterPasswordError(error)
        self.completion(.failure(AccountError.unknown))
    }
}

extension MigrationProgressViewModel: AccountCryptoChangerServiceDelegate {
    func didProgress(_ progression: AccountCryptoChangerService.Progression) {
        DispatchQueue.main.async {
            switch progression {
            case .downloading:
                self.progressionText = L10n.Localizable.accountMigrationProgressDownLoading
            case .decrypting, .reEncrypting:
                self.progressionText = L10n.Localizable.accountMigrationProgressEncrypting
            case .uploading: break
            case .finalizing:
                self.progressionText = L10n.Localizable.accountMigrationProgressFinalizing
            }
        }
    }

    func didFinish(with result: Result<Session, AccountCryptoChangerError>) {
        DispatchQueue.main.async {
            self.isProgress = false
            switch result {
            case let .success(session):
                self.isSuccess = true
                self.progressionText = self.type.isMasterPasswordToMasterPassword ? L10n.Localizable.changeMasterPasswordSuccessHeadline : L10n.Localizable.accountMigrationProgressFinished
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                    guard let self = self else {
                        return
                    }

                    if self.type.isMasterPasswordToMasterPassword && Device.isMac {
                        self.currentAlert = .init(reason: .masterPasswordSuccess) {  [weak self] in
                            self?.didComplete(session)
                        }
                    } else {
                        self.didComplete(session)
                    }
                }
            case let .failure(error):
                self.isSuccess = false
                self.progressionText = L10n.Localizable.changeMasterPasswordErrorTitle
                self.currentAlert = .init(reason: .failure) {  [weak self] in
                    self?.didFail(error)
                }
            }
        }
    }

    func logChangeMasterPasswordError(_ error: AccountCryptoChangerError) {
        activityReporter.report(UserEvent.ChangeMasterPassword(errorName: error.userTrackingErrorName, flowStep: .error))
    }

    func logChangeMasterPasswordStep(_ step: Definition.FlowStep) {
        guard case .masterPasswordToMasterPassword = type else {
            return
        }
        activityReporter.report(UserEvent.ChangeMasterPassword(flowStep: step))
    }
}

private extension AccountCryptoChangerError {

    var userTrackingErrorName: Definition.ChangeMasterPasswordError {
        guard case let .encryptionError(accountMigraterError) = self else {
            return .syncFailedError
        }
        switch accountMigraterError.step {
        case .downloading:
            return .downloadError
        case .reEncrypting:
            return .cipherError
        case .uploading:
            return .uploadError
        case .delegateCompleting, .notifyingMasterKeyDone:
            return .confirmationError
        }
    }
}
