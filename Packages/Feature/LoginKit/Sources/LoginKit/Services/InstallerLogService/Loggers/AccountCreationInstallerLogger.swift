import Foundation
import DashlaneReportKit
import CorePasswords
import SwiftTreats

public struct AccountCreationInstallerLogger {
    private let installerLogService: InstallerLogServiceProtocol
    private let sessionId: String = UUID().uuidString

    public init(installerLogService: InstallerLogServiceProtocol) {
        self.installerLogService = installerLogService
    }

    public enum Event {
        case email(action: Action.Email)
        case masterPasswordInitialEntry(action: Action.MasterPasswordInitialEntry)
        case masterPasswordConfirmation(action: Action.MasterPasswordConfirmation)
        case fastLocalSetup(action: Action.FastLocalSetup)
        case recap(action: Action.Recap)
        case finishingAccountCreation

        public enum Action {
            public enum Email: String {
                case shown
                case next
                case back
                case accountAlreadyExists
                case emailNotValid
                case emailFieldEmpty
            }

            public enum MasterPasswordInitialEntry: String {
                case shown
                case next
                case back
                case tipsShown
                case passwordTooGuessable
                case passwordVeryGuessable
                case passwordSomewhatGuessable
                case passwordSafelyUnguessable
                case passwordVeryUnguessable
            }

            public enum MasterPasswordConfirmation: String {
                case shown
                case next
                case back
                case passwordsNotMatching
                case passwordsMatching
            }

            public enum FastLocalSetup: String {
                case shown
                case biometricAuthenticationCannotBeShown
                case touchIDEnabled
                case touchIDDisabled
                case faceIDEnabled
                case faceIDDisabled
                case masterPasswordResetEnabled
                case masterPasswordResetDisabled
            }

            public enum Recap: String {
                case shown
                case next
                case back
                case termsAndConditionsAccepted
                case emailMarketingAccepted
                case emailMarketingDeclined
                case termsAndConditionsAcceptanceMissing
            }
        }

        var step: String {
            switch self {
            case .email:
                return "69.1"
            case .masterPasswordInitialEntry:
                return "69.2"
            case .masterPasswordConfirmation:
                return "69.3"
            case .fastLocalSetup:
                return "69.4"
            case .recap:
                return "69.5"
            case .finishingAccountCreation:
                return "69.6"
            }
        }

        var subtype: String {
            switch self {
            case .email:
                return "email"
            case .masterPasswordInitialEntry:
                return "masterPassword"
            case .masterPasswordConfirmation:
                return "masterPasswordConfirmation"
            case .fastLocalSetup:
                return "fastLocalSetup"
            case .recap:
                return "recap"
            case .finishingAccountCreation:
                return "finishingAccountCreation"
            }
        }

        var action: String? {
            switch self {
            case .email(action: let action):
                return action.rawValue
            case .masterPasswordInitialEntry(action: let action):
                return action.rawValue
            case .masterPasswordConfirmation(action: let action):
                return action.rawValue
            case .fastLocalSetup(action: let action):
                return action.rawValue
            case .recap(action: let action):
                return action.rawValue
            case .finishingAccountCreation:
                return nil
            }
        }
    }

    public func log(_ event: Event) {
        let log = InstallerLogCode69LoginAndAccountCreation(step: event.step,
                                                            loginSession: self.sessionId,
                                                            type: .createAccount,
                                                            subType: event.subtype,
                                                            action: event.action)
        installerLogService.post(log)

                event.legacyLogs.forEach { installerLogService.post($0) }
    }
}

private extension AccountCreationInstallerLogger.Event {
    var legacyLogs: [InstallerLogCodeProtocol] {
        switch self {
        case .email(action: let action):
            return legacyLogs(for: action)
        case .masterPasswordInitialEntry(action: let action):
            return legacyLogs(for: action)
        case .masterPasswordConfirmation(action: let action):
            return legacyLogs(for: action)
        case .fastLocalSetup(action: let action):
            return legacyLogs(for: action)
        case .recap(action: let action):
            return legacyLogs(for: action)
        case .finishingAccountCreation:
            return [InstallerLogCode17Installer(step: "17.40.1"), InstallerLogCode17Installer(step: "17.26"), InstallerLogCode17Installer(step: "17.31")]
        }
    }

    private func legacyLogs(for action: Action.Email) -> [InstallerLogCodeProtocol] {
        switch action {
        case .back:
            return [InstallerLogCode17Installer(step: "17.2"), InstallerLogCode17Installer(step: "17.215")]
        case .accountAlreadyExists:
            return [InstallerLogCode17Installer(step: "17.22"), InstallerLogCode17Installer(step: "17.25")]
        case .emailNotValid:
            return [InstallerLogCode17Installer(step: "17.24")]
        case .emailFieldEmpty:
            return [InstallerLogCode17Installer(step: "17.24.1")]
        default:
            return [InstallerLogCodeProtocol]()
        }
    }

    private func legacyLogs(for action: Action.FastLocalSetup) -> [InstallerLogCodeProtocol] {
        switch action {
        case .biometricAuthenticationCannotBeShown:
            return [InstallerLogCode17Installer(step: "17.36")]
        case .touchIDEnabled:
            return [InstallerLogCode17Installer(step: "17.37")]
        case .touchIDDisabled:
            return [InstallerLogCode17Installer(step: "17.38")]
        case .faceIDEnabled:
            return [InstallerLogCode17Installer(step: "17.370")]
        case .faceIDDisabled:
            return [InstallerLogCode17Installer(step: "17.380")]
        default:
            return [InstallerLogCodeProtocol]()
        }

    }

    private func legacyLogs(for action: Action.MasterPasswordInitialEntry) -> [InstallerLogCodeProtocol] {
        switch action {
        case .shown:
            return [InstallerLogCode17Installer(step: "17.39")]
        case .passwordTooGuessable:
            return [InstallerLogCode17Installer(step: "17.27")]
        case .passwordVeryGuessable:
            return [InstallerLogCode17Installer(step: "17.27")]
        case .passwordSomewhatGuessable:
            return [InstallerLogCode17Installer(step: "17.28")]
        case .passwordSafelyUnguessable:
            return [InstallerLogCode17Installer(step: "17.28")]
        case .passwordVeryUnguessable:
            return [InstallerLogCode17Installer(step: "17.28")]
        default:
            return [InstallerLogCodeProtocol]()
        }
    }

    private func legacyLogs(for action: Action.MasterPasswordConfirmation) -> [InstallerLogCodeProtocol] {
        switch action {
        case .back:
            return [InstallerLogCode17Installer(step: "17.45")]
        case .passwordsNotMatching:
            return [InstallerLogCode17Installer(step: "17.29")]
        case .passwordsMatching:
            return [InstallerLogCode17Installer(step: "17.30")]
        default:
            return [InstallerLogCodeProtocol]()
        }
    }

    private func legacyLogs(for action: Action.Recap) -> [InstallerLogCodeProtocol] {
        switch action {
        case .shown:
            return [InstallerLogCode17Installer(step: "17.40.0")]
        case .termsAndConditionsAccepted:
            let privacyPolicyAndToS = "1"
            let personalEmails = "2"

            return [privacyPolicyAndToS, personalEmails].map {
                InstallerLogCode17Installer(step: "17.40.1.\($0).1")
            }
        case .emailMarketingAccepted:
            let emailsTips = "3"
            let emailsOffers = "4"

            return [emailsTips, emailsOffers].map {
                InstallerLogCode17Installer(step: "17.40.1.\($0).1")
            }
        case .emailMarketingDeclined:
            let emailsTips = "3"
            let emailsOffers = "4"

            return [emailsTips, emailsOffers].map {
                InstallerLogCode17Installer(step: "17.40.1.\($0).0")
            }
        default:
            return [InstallerLogCodeProtocol]()
        }
    }
}

public extension AccountCreationInstallerLogger {
    func logBiometricAuthenticationActivation(_ type: Biometry?, isEnabled: Bool) {
        switch type {
        case .touchId:
            if isEnabled {
                log(.fastLocalSetup(action: .touchIDEnabled))
            } else {
                log(.fastLocalSetup(action: .touchIDDisabled))
            }
        case .faceId:
            if isEnabled {
                log(.fastLocalSetup(action: .faceIDEnabled))
            } else {
                log(.fastLocalSetup(action: .faceIDDisabled))
            }
        case .none:
            break
        }
    }

    func logMasterPasswordResetActivation(isEnabled: Bool) {
        if isEnabled {
            log(.fastLocalSetup(action: .masterPasswordResetEnabled))
        } else {
            log(.fastLocalSetup(action: .masterPasswordResetDisabled))
        }
    }

    func logPasswordStrengthWhenValidationIsRequested(_ passwordStrength: PasswordStrength) {
        switch passwordStrength {
        case .tooGuessable:
            log(.masterPasswordInitialEntry(action: .passwordTooGuessable))
        case .veryGuessable:
            log(.masterPasswordInitialEntry(action: .passwordVeryGuessable))
        case .somewhatGuessable:
            log(.masterPasswordInitialEntry(action: .passwordSomewhatGuessable))
        case .safelyUnguessable:
            log(.masterPasswordInitialEntry(action: .passwordSafelyUnguessable))
        case .veryUnguessable:
            log(.masterPasswordInitialEntry(action: .passwordVeryUnguessable))
        }
    }
}
