import Foundation
import DashlaneReportKit

public class SSOLoginInstallerLogger {

    public enum Event {
        case loginEmailIsProvisionedSSOAccount
        case loginEmailIsNotProvisionedSSOAccount
        case createAccountEmailWillProvisionAccount
        case successfulLoginOnSSOPage
        case failedLoginOnSSOPage
        case ssoJoinTeamPage

        enum Action: String {
            case `continue`
            case createAccount
        }

        enum SubAction: String {
            case notProvisioned
            case success
            case cancel
        }

        var step: String {
            switch self {
            case .createAccountEmailWillProvisionAccount:
                return "69.14.1"
            case .loginEmailIsProvisionedSSOAccount:
                return "69.14.2"
            case .loginEmailIsNotProvisionedSSOAccount:
                return "69.14.3"
            case .successfulLoginOnSSOPage:
                return "69.14.4"
            case .failedLoginOnSSOPage:
                return "69.14.4.1"
            case .ssoJoinTeamPage:
                return "69.14.5"
            }
        }

        var type: InstallerLogCode69LoginAndAccountCreation.TypeType {
            switch self {
            case .loginEmailIsProvisionedSSOAccount,
                 .loginEmailIsNotProvisionedSSOAccount,
                 .successfulLoginOnSSOPage,
                 .failedLoginOnSSOPage,
                 .ssoJoinTeamPage:
                return .login
            case .createAccountEmailWillProvisionAccount:
                return .createAccount
            }
        }

        var subtype: String {
            return "ssoLogin"
        }

        var action: Action {
            switch self {
            case .loginEmailIsProvisionedSSOAccount,
                 .loginEmailIsNotProvisionedSSOAccount,
                 .successfulLoginOnSSOPage,
                 .failedLoginOnSSOPage,
                 .createAccountEmailWillProvisionAccount:
                return .continue
            case .ssoJoinTeamPage:
                return .createAccount
            }
        }

        var subAction: SubAction? {
            switch self {
            case .loginEmailIsNotProvisionedSSOAccount:
                return .notProvisioned
            case .successfulLoginOnSSOPage:
                return .success
            case .failedLoginOnSSOPage:
                return .cancel
            default:
                return nil
            }
        }
    }

    let logService: InstallerLogServiceProtocol
    let sessionId: String

    public init(logService: InstallerLogServiceProtocol) {
        self.logService = logService
        self.sessionId = UUID().uuidString
    }

    public func log(_ event: Event) {
        let log = InstallerLogCode69LoginAndAccountCreation(step: event.step,
                                                            loginSession: self.sessionId,
                                                            type: event.type,
                                                            subType: event.subtype,
                                                            action: event.action.rawValue,
                                                            subAction: event.subAction?.rawValue)
        DispatchQueue.global(qos: .utility).async {
            self.logService.post(log)
        }
    }
}
