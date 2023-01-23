import Foundation


enum LifeCycleLogEvent {
    case started(domain: String?, preselectedCredential: Bool, alreadyAuthenticated: Bool)
    case completed(CredentialSelection)
    case failed(userInteractionRequired: Bool = false)
}

extension LifeCycleLogEvent: TachyonLoggable {
    var type: String {
        switch self {
        case .started:
            return "AutofillStarted"
        case .completed:
            return "AutofillCompleted"
        case .failed:
            return "AutofillFailed"
        }
    }

    var logData: TachyonLogData {
        switch self {
        case let .started(domain, preselectedCredential, alreadyAuthenticated):
            let action = preselectedCredential ? "preselected" : nil
            let subAction = alreadyAuthenticated ? "alreadyAuthenticated" : nil
            return TachyonLogData(type: type, action: action, subAction: subAction, domain: domain)
        case let .failed(userInteractionRequired):
            let action = userInteractionRequired ? "userInteractionRequired" : nil
            return TachyonLogData(type: type, action: action)
        case let .completed(selection):
            let action: String? = {
                switch selection.selectionOrigin {
                case .quickTypeBar:
                    return "preselection"
                default:
                    return nil
                }
            }()
            let domain = selection.credential.url?.domain?.name
            return TachyonLogData(type: type, action: action, domain: domain)
        }
    }
}
