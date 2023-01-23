import Foundation
import DashlaneReportKit

struct DWMLogService {

    enum Event {
        case emailRegistrationScreenDisplayed
        case emailRegistrationScreenSkipped
        case checkForBreachesTapped
        case emailRegistrationRequestSent
        case openMailAppDisplayed
        case openMailAppTapped
        case confirmedEmailDisplayed
        case confirmedEmailTapped
        case mailAppDisplayed(app: MailApp)
        case mailAppTapped(app: MailApp)
        case fetchingEmailConfirmationDisplayed
        case emailConfirmationErrorDisplayed
        case emailConfirmationErrorTryAgainTapped
        case emailConfirmationErrorSkipped
        case emailConfirmedScreenDisplayed
        case breachesFound(numberOfBreaches: Int)
        case breachesFoundWithPassword(numberOfBreaches: Int)
        case everythingLooksGreatDisplayed
        case emailRegistrationFromChecklistDisplayed
        case emailConfirmedFromChecklistDisplayed
        case noBreachesFoundMessageDisplayed
        case breachesListDisplayed
        case breachesListItemDeleted(domain: String)
        case breachDetailViewDisplayed(passwordFound: Bool, domain: String)
        case manualChangeStarted(domain: String) 
        case changePasswordTapped(domain: String) 
        case miniBrowserDisplayed(domain: String)
        case securedItemSaveTapped(disabled: Bool)
        case miniBrowserInstructionsDisplayed
        case emailCopied
        case passwordCopied
        case passwordGeneratorDisplayed
        case generatedPasswordCopied
        case savingNewPasswordDisplayed(domain: String)
        case securedItemSavedConfirmationDisplayed(domain: String)
        case lastChanceScanPromptDisplayed
        case lastChanceScanPromptDismissed
        case lastChanceScanPromptAccepted

                case emailRegistrationInvalidEmailError
        case emailRegistrationConnectionError
        case emailRegistrationUnexpectedError
        case emailConfirmationStatusUpdateConnectionError
        case emailConfirmationStatusUpdateUnexpectedError
        case fetchingBreachesConnectionError
        case fetchingBreachesUnexpectedError
        case miniBrowserCannotBeOpenedError
        case itemCannotBeSavedError

        var subtype: String {
            switch self {
            case .emailRegistrationScreenDisplayed:
                return "emailRegistrationScreen"
            case .emailRegistrationScreenSkipped:
                return "emailRegistrationScreen"
            case .checkForBreachesTapped:
                return "checkForBreaches"
            case .emailRegistrationRequestSent:
                return "emailRegistrationRequest"
            case .openMailAppDisplayed:
                return "openMailApp"
            case .openMailAppTapped:
                return "openMailApp"
            case .confirmedEmailDisplayed:
                return "confirmedEmail"
            case .confirmedEmailTapped:
                return "confirmedEmail"
            case .mailAppDisplayed:
                return "mailApp"
            case .mailAppTapped:
                return "mailApp"
            case .fetchingEmailConfirmationDisplayed:
                return "fetchingEmailConfirmation"
            case .emailConfirmationErrorDisplayed:
                return "emailConfirmationError"
            case .emailConfirmationErrorTryAgainTapped:
                return "emailConfirmationError"
            case .emailConfirmationErrorSkipped:
                return "emailConfirmationError"
            case .emailConfirmedScreenDisplayed:
                return "emailConfirmedScreen"
            case .breachesFound:
                return "breachesFound"
            case .breachesFoundWithPassword:
                return "breachesFoundWithPassword"
            case .everythingLooksGreatDisplayed:
                return "everythingLooksGreat"
            case .emailRegistrationFromChecklistDisplayed:
                return "emailRegistrationFromChecklist"
            case .emailConfirmedFromChecklistDisplayed:
                return "emailConfirmedFromChecklist"
            case .noBreachesFoundMessageDisplayed:
                return "noBreachesFoundMessage"
            case .breachesListDisplayed:
                return "breachesList"
            case .breachesListItemDeleted:
                return "breachesList"
            case .breachDetailViewDisplayed:
                return "breachDetailView"
            case .manualChangeStarted:
                return "breachDetailView"
            case .changePasswordTapped:
                return "breachDetailView"
            case .miniBrowserDisplayed:
                return "miniBrowser"
            case .securedItemSaveTapped:
                return "saveSecuredItem"
            case .miniBrowserInstructionsDisplayed:
                return "miniBrowserInstructions"
            case .emailCopied:
                return "miniBrowser"
            case .passwordCopied:
                return "miniBrowser"
            case .passwordGeneratorDisplayed:
                return "miniBrowserPasswordGenerator"
            case .generatedPasswordCopied:
                return "miniBrowser"
            case .savingNewPasswordDisplayed:
                return "savingNewPassword"
            case .securedItemSavedConfirmationDisplayed:
                return "securedItemSaved"
            case .lastChanceScanPromptDisplayed:
                return "lastChanceScanPrompt"
            case .lastChanceScanPromptDismissed:
                return "lastChanceScanPrompt"
            case .lastChanceScanPromptAccepted:
                return "lastChanceScanPrompt"
            case .emailRegistrationInvalidEmailError:
                return "emailRegistrationError"
            case .emailRegistrationConnectionError:
                return "emailRegistrationError"
            case .emailRegistrationUnexpectedError:
                return "emailRegistrationError"
            case .emailConfirmationStatusUpdateConnectionError:
                return "emailConfirmationStatusUpdateError"
            case .emailConfirmationStatusUpdateUnexpectedError:
                return "emailConfirmationStatusUpdateError"
            case .fetchingBreachesConnectionError:
                return "fetchingBreachesError"
            case .fetchingBreachesUnexpectedError:
                return "fetchingBreachesError"
            case .miniBrowserCannotBeOpenedError:
                return "miniBrowserError"
            case .itemCannotBeSavedError:
                return "securedItemError"
            }
        }

        var action: String {
            switch self {
            case .emailRegistrationScreenDisplayed:
                return "display"
            case .emailRegistrationScreenSkipped:
                return "skip"
            case .checkForBreachesTapped:
                return "tap"
            case .emailRegistrationRequestSent:
                return "success"
            case .openMailAppDisplayed:
                return "display"
            case .openMailAppTapped:
                return "tap"
            case .confirmedEmailDisplayed:
                return "display"
            case .confirmedEmailTapped:
                return "tap"
            case .mailAppDisplayed:
                return "display"
            case .mailAppTapped:
                return "tap"
            case .fetchingEmailConfirmationDisplayed:
                return "display"
            case .emailConfirmationErrorDisplayed:
                return "display"
            case .emailConfirmationErrorTryAgainTapped:
                return "tryAgain"
            case .emailConfirmationErrorSkipped:
                return "skip"
            case .emailConfirmedScreenDisplayed:
                return "display"
            case .breachesFound(numberOfBreaches: let numberOfBreaches):
                return String(numberOfBreaches)
            case .breachesFoundWithPassword(numberOfBreaches: let numberOfBreaches):
                return String(numberOfBreaches)
            case .everythingLooksGreatDisplayed:
                return "display"
            case .emailRegistrationFromChecklistDisplayed:
                return "display"
            case .emailConfirmedFromChecklistDisplayed:
                return "display"
            case .noBreachesFoundMessageDisplayed:
                return "display"
            case .breachesListDisplayed:
                return "display"
            case .breachesListItemDeleted:
                return "delete"
            case .breachDetailViewDisplayed:
                return "display"
            case .manualChangeStarted:
                return "manualChange"
            case .changePasswordTapped:
                return "changePasswordTapped"
            case .miniBrowserDisplayed:
                return "display"
            case .securedItemSaveTapped:
                return "tap"
            case .miniBrowserInstructionsDisplayed:
                return "display"
            case .emailCopied:
                return "copy"
            case .passwordCopied:
                return "copy"
            case .passwordGeneratorDisplayed:
                return "display"
            case .generatedPasswordCopied:
                return "copy"
            case .savingNewPasswordDisplayed:
                return "display"
            case .securedItemSavedConfirmationDisplayed:
                return "display"
            case .lastChanceScanPromptDisplayed:
                return "display"
            case .lastChanceScanPromptDismissed:
                return "dismiss"
            case .lastChanceScanPromptAccepted:
                return "accept"
            case .emailRegistrationInvalidEmailError:
                return "invalidEmail"
            case .emailRegistrationConnectionError:
                return "connection"
            case .emailRegistrationUnexpectedError:
                return "unexpected"
            case .emailConfirmationStatusUpdateConnectionError:
                return "connection"
            case .emailConfirmationStatusUpdateUnexpectedError:
                return "unexpected"
            case .fetchingBreachesConnectionError:
                return "connection"
            case .fetchingBreachesUnexpectedError:
                return "unexpected"
            case .miniBrowserCannotBeOpenedError:
                return "noValidUrl"
            case .itemCannotBeSavedError:
                return "couldNotBeSaved"
            }
        }

        var subaction: String? {
            switch self {
            case .mailAppDisplayed(app: let app):
                return app.rawValue
            case .mailAppTapped(app: let app):
                return app.rawValue
            case .breachDetailViewDisplayed(passwordFound: let passwordFound, _):
                return passwordFound ? "passwordFound" : "passwordMissing"
            case .securedItemSaveTapped(disabled: let disabled):
                return disabled ? "disabled" : "enabled"
            case .emailCopied:
                return "email"
            case .passwordCopied:
                return "password"
            case .generatedPasswordCopied:
                return "generatedPassword"
            default:
                return nil
            }
        }

        var website: String? {
            switch self {
            case .breachesListItemDeleted(domain: let domain):
                return domain
            case .breachDetailViewDisplayed(_, domain: let domain):
                return domain
            case .manualChangeStarted(domain: let domain):
                return domain
            case .changePasswordTapped(domain: let domain):
                return domain
            case .miniBrowserDisplayed(domain: let domain):
                return domain
            case .securedItemSavedConfirmationDisplayed(domain: let domain):
                return domain
            case .savingNewPasswordDisplayed(domain: let domain):
                return domain
            default:
                return nil
            }
        }
    }

    let usageLogService: UsageLogServiceProtocol

    func log(_ event: Event) {
        let log = UsageLogCode75GeneralActions(type: "dwm_in_onboarding",
                                               subtype: event.subtype,
                                               action: event.action,
                                               subaction: event.subaction,
                                               website: event.website)

        self.usageLogService.post(log)
    }
}

extension UsageLogServiceProtocol {
    var dwmLogService: DWMLogService {
        return DWMLogService(usageLogService: self)
    }
}

extension DWMLogService {
    static var fakeService: DWMLogService {
        DWMLogService(usageLogService: UsageLogService.fakeService)
    }
}
