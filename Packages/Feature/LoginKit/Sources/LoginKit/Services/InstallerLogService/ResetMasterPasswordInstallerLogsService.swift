import Foundation
import DashlaneReportKit
import CoreNetworking

public class ResetMasterPasswordInstallerLogsService {

    public enum Event {
        case forgotWithAbilityToResetMP(action: Action.ForgotWithAbilityToResetMP, origin: Origin.ForgotWithAbilityToResetMP)
        case errorMessageWithResetOption(action: Action.ErrorMessageWithResetOption, origin: Origin.ErrorMessageWithResetOption)
        case resetMasterPasswordStart(result: Action.ResetMasterPasswordStart, origin: Origin.ResetMasterPasswordStart)
        case resetMasterPasswordConfirmationDialog(action: Action.Dialog, origin: Origin.ResetMasterPasswordConfirmationDialog)
        case failedAttemptsLimitError(action: Action.FailedAttemptsLimitError, origin: Origin.ResetMasterPasswordStart)

        public enum Origin {
            public enum ForgotWithAbilityToResetMP: String {
                case login
            }

            public enum ErrorMessageWithResetOption: String {
                case login
            }

            public enum ResetMasterPasswordStart: String {
                case login
            }

            public enum ResetMasterPasswordConfirmationDialog: String {
                case login
            }

            public enum FailedAttemptsLimitErrorShown: String {
                case login
            }
        }

        public enum Action {
            public enum Dialog: String {
                case display
                case confirm
                case cancel
            }

            public enum ForgotWithAbilityToResetMP: String {
                case select
            }

            public enum IncorrectMasterPasswordError: String {
                case show
                case select
            }

            public enum ErrorMessageWithResetOption: String {
                case show
                case select
            }

            public enum ResetMasterPasswordStart {
                case success
                case failure(subtype: Subtype)

                public enum Subtype: String {
                    case incorrectMasterPasswordInResetContainer
                    case resetMasterPasswordInternalError
                    case userCanceledRequest
                }
            }

            public enum FailedAttemptsLimitError: String {
                case show
            }
        }

        public var type: String {
            switch self {
            case .forgotWithAbilityToResetMP(_, let origin):
                return origin.rawValue
            case .errorMessageWithResetOption(_, let origin):
                return origin.rawValue
            case .resetMasterPasswordStart(_, let origin):
                return origin.rawValue
            case .resetMasterPasswordConfirmationDialog(_, let origin):
                return origin.rawValue
            case .failedAttemptsLimitError(_, let origin):
                return origin.rawValue
            }

        }

        public var subtype: String {
            switch self {
            case .forgotWithAbilityToResetMP:
                return "forgotWithAbilityToResetMP"
            case .errorMessageWithResetOption:
                return "errorMessageWithResetOption"
            case .resetMasterPasswordStart:
                return "resetMasterPasswordStart"
            case .resetMasterPasswordConfirmationDialog:
                return "resetMasterPasswordConfirmationDialog"
            case .failedAttemptsLimitError:
                return "failedAttemptsLimitErrorShown"
            }
        }

        public var action: String {
            switch self {
            case .forgotWithAbilityToResetMP(let action, _):
                return action.rawValue
            case .errorMessageWithResetOption(let action, _):
                return action.rawValue
            case .resetMasterPasswordStart(let result, _):
                switch result {
                case .success:
                    return "success"
                case .failure(subtype: let subtype):
                    return subtype.rawValue
                }
            case .resetMasterPasswordConfirmationDialog(let action, _):
                return action.rawValue
            case .failedAttemptsLimitError(let action, _):
                return action.rawValue
            }
        }
    }

    let installerLogService: InstallerLogServiceProtocol
    let sessionId: String

    public init(logService: InstallerLogServiceProtocol) {
        self.installerLogService = logService
        self.sessionId = UUID().uuidString
    }

    public func log(_ event: Event) {
        let log = InstallerLogCode69LoginAndAccountCreation(step: "69.12",
                                                            loginSession: self.sessionId,
                                                            type: .login,
                                                            subType: event.subtype,
                                                            action: event.action)
        self.installerLogService.post(log)
    }
}
