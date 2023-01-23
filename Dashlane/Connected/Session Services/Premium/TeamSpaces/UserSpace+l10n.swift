import Foundation
import DashlaneAppKit
import CorePremium

extension UserSpace {
    var teamName: String {
        switch self {
            case .personal:
                return L10n.Localizable.teamSpacesPersonalSpaceName
            case .both:
                return L10n.Localizable.teamSpacesAllSpaces
            case let .business(space):
                return space.space.teamName ?? ""
        }
    }

    var letter: String? {
        switch self {
            case .personal:
                return L10n.Localizable.teamSpacesPersonalSpaceInitial
            case .both:
                return ""
            case let .business(businessInfo):
                return businessInfo.space.letter
        }
    }
}
