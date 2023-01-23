import Foundation


enum CredentialListEvent {
    case displayed(showAllOptionAvailable: Bool)
    case cancel
    case showAllCredentials
}

extension CredentialListEvent: TachyonLoggable {
    var action: String {
        switch self {
        case .displayed:
            return "Show"
        case .cancel:
            return "Cancel"
        case .showAllCredentials:
            return "ShowAll"
        }
    }
    var logData: TachyonLogData {
        var subtype: String? = nil
        if case .displayed(true) = self {
            subtype = "ShowAll"
        }
        return .init(type: "CredentialList", subType: subtype, action: action)
    }
}
