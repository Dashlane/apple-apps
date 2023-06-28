import Foundation
import CoreSession
import CorePersonalData
import CoreUserTracking
import DashlaneAppKit
import SwiftTreats
import Combine
import CoreLocalization
import CoreNetworking
import DashTypes

class MigrationProgressViewModel: ObservableObject, SessionServicesInjecting {

    enum Context {
        case changeMP
        case accountRecovery
        case accountTypeMigration

        var successText: String {
            switch self {
            case .changeMP:
               return L10n.Localizable.changeMasterPasswordSuccessHeadline
            case .accountTypeMigration:
                return L10n.Localizable.accountMigrationProgressFinished
            case .accountRecovery:
                return CoreLocalization.L10n.Core.recoveryKeyLoginSuccessMessage
            }
        }

        var reason: UserDeviceAPIClient.Accountrecovery.Deactivate.Reason {
            switch self {
            case .accountRecovery:
                return .keyUsed
            case .changeMP, .accountTypeMigration:
                return .vaultKeyChange
            }
        }
    }

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
    var progressionText: String

    @Published
    var currentAlert: MigrationAlert?

    let completion: (Result<Session, Error>) -> Void
    let type: MigrationType
    let activityReporter: ActivityReporterProtocol
    let accountCryptoChangerService: AccountCryptoChangerServiceProtocol
    var subscriptions = Set<AnyCancellable>()
    let context: Context
    let userDeviceAPIClient: UserDeviceAPIClient
    let syncedSettings: SyncedSettingsService
    let logger: Logger
    let accountRecoveryKeyService: AccountRecoveryKeyService
    init(type: MigrationType,
         accountCryptoChangerService: AccountCryptoChangerServiceProtocol,
         accountRecoveryKeyService: AccountRecoveryKeyService,
         userDeviceAPIClient: UserDeviceAPIClient,
         activityReporter: ActivityReporterProtocol,
         syncedSettings: SyncedSettingsService,
         context: MigrationProgressViewModel.Context,
         logger: Logger,
         isProgress: Bool = true,
         isSuccess: Bool = true,
         completion: @escaping (Result<Session, Error>) -> Void) {
        self.type = type
        self.completion = completion
        self.isProgress = isProgress
        self.isSuccess = isSuccess
        self.activityReporter = activityReporter
        self.syncedSettings = syncedSettings
        self.userDeviceAPIClient = userDeviceAPIClient
        self.context = context
        self.logger = logger
        self.accountCryptoChangerService = accountCryptoChangerService
        self.accountRecoveryKeyService = accountRecoveryKeyService
        progressionText = context == .accountRecovery ? CoreLocalization.L10n.Core.recoveryKeyLoginProgressMessage : L10n.Localizable.accountMigrationProgressDownLoading
        accountCryptoChangerService.progressPublisher.receive(on: DispatchQueue.main).sink { [weak self] state in
            guard let self = self else {
                return
            }
            switch state {
            case let .inProgress(progression):
                self.didProgress(progression)
            case let .finished(result):
                self.didFinish(with: result)
            }
        }.store(in: &subscriptions)
    }

    private func didComplete(_ session: Session) {
        logChangeMasterPasswordStep(.complete)
        Task {
            do {
                _ = try await accountRecoveryKeyService.deactivateAccountRecoveryKey(for: context.reason)
                if context == .accountRecovery {
                    activityReporter.report(UserEvent.UseAccountRecoveryKey(flowStep: .complete))
                }
            } catch {
                logger.fatal("Account Recovery Key auto disabling failed", error: error)
            }
        }
        self.completion(.success(session))
    }

    private func didFail(_ error: AccountCryptoChangerError) {
        logChangeMasterPasswordError(error)
        self.completion(.failure(AccountError.unknown))
    }
}

extension MigrationProgressViewModel {
    func didProgress(_ progression: AccountCryptoChangerService.Progression) {
        guard context != .accountRecovery else {
            progressionText = CoreLocalization.L10n.Core.recoveryKeyLoginProgressMessage
            return
        }
        switch progression {
        case .downloading:
            progressionText = L10n.Localizable.accountMigrationProgressDownLoading
        case .decrypting, .reEncrypting:
            progressionText = L10n.Localizable.accountMigrationProgressEncrypting
        case .uploading: break
        case .finalizing:
            progressionText = L10n.Localizable.accountMigrationProgressFinalizing
        }
    }

    func didFinish(with result: Result<Session, AccountCryptoChangerError>) {
        self.isProgress = false
        switch result {
        case let .success(session):
            self.isSuccess = true
            self.progressionText = context.successText
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
            self.didFail(error)
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

extension MigrationProgressViewModel {
    static func mock(inProgress: Bool = true, isSuccess: Bool = true) -> MigrationProgressViewModel {
        MigrationProgressViewModel(type: .masterPasswordToMasterPassword,
                                   accountCryptoChangerService: AccountCryptoChangerService.mock,
                                   accountRecoveryKeyService: .mock,
                                   userDeviceAPIClient: .fake,
                                   activityReporter: .fake,
                                   syncedSettings: .mock,
                                   context: .changeMP,
                                   logger: LoggerMock(),
                                   isProgress: inProgress,
                                   isSuccess: isSuccess,
                                   completion: {_ in })
    }
}
