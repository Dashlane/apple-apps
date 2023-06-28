import Foundation
import CorePremium
import CoreLocalization

public extension UserSpace {
    var teamName: String {
        switch self {
            case .personal:
                return L10n.Core.teamSpacesPersonalSpaceName
            case .both:
                return L10n.Core.teamSpacesAllSpaces
            case let .business(space):
                return space.space.teamName ?? ""
        }
    }

    var letter: String? {
        switch self {
            case .personal:
                return L10n.Core.teamSpacesPersonalSpaceInitial
            case .both:
                return ""
            case let .business(businessInfo):
                return businessInfo.space.letter
        }
    }
}
