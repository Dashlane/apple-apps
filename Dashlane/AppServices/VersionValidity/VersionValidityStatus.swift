import Foundation
import CoreSettings

enum VersionValidityStatus: Equatable {
    case valid
    case updateRecommended(updatePossible: Bool)
    case updateStronglyEncouraged(updatePossible: Bool, helpCenterUrl: String)
    case updateRequired(updatePossible: Bool, daysBeforeExpiration: Int?, helpCenterUrl: String)
    case expired(updatePossible: Bool, helpCenterUrl: String)

    static var defaultHelpCenterUrl: String {
        return "_"
    }

    var isValid: Bool {
        switch self {
        case .expired:
            return false
        default:
            return true
        }
    }

    init(fromServerResponse response: VersionValidityStatusServerResponse) {
        switch response.status {
        case .validVersion:
            self = .valid
        case .updateRecommended:
            self = .updateRecommended(updatePossible: response.updatePossible ?? true)
        case .updateStronglyEncouraged:
            self = .updateStronglyEncouraged(updatePossible: response.updatePossible ?? true, helpCenterUrl: response.helpCenterArticle ?? Self.defaultHelpCenterUrl)
        case .updateRequired:
            self = .updateRequired(updatePossible: response.updatePossible ?? true, daysBeforeExpiration: response.daysBeforeExpiration, helpCenterUrl: response.helpCenterArticle ?? Self.defaultHelpCenterUrl)
        case .expiredVersion:
            self = .expired(updatePossible: response.updatePossible ?? true, helpCenterUrl: response.helpCenterArticle ?? Self.defaultHelpCenterUrl)
        }
    }
}
