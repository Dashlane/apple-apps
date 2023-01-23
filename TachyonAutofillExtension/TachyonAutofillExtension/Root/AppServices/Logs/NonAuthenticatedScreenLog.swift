import Foundation

enum NonAuthenticatedScreenLogEvent {
    case displayed(reason: String)
    case goToMainApp
    case cancel
    case moreInfo
}

extension NonAuthenticatedScreenLogEvent: TachyonLoggable {
    
    var action: String {
        switch self {
        case .displayed:
            return "show"
        case .goToMainApp:
            return "gotoMainAppClicked"
        case .cancel:
            return "cancel"
        case .moreInfo:
            return "moreInfo"
        }
    }
    
    var logData: TachyonLogData {
        let type = "NonAuthenticatedScreen"
        var subtype: String? = nil
        if case let .displayed(reason) = self {
            subtype = reason
        }
        return TachyonLogData(type: type, subType: subtype, action: self.action)
    }
}
