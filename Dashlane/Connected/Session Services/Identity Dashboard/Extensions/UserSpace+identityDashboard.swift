import Foundation
import DashlaneAppKit
import CorePremium

extension UserSpace {
    var identityDashboardSpaceId: String? {
        switch self {
            case .personal:
                return ""
            case .both:
                return nil
            case let .business(space):
                return space.space.teamId
        }
    }

    var identityDashboardAnonymousLogId: String? {
        switch self {
            case .personal:
                return "SPACE_DEFAULT"
            case .both:
                return "SPACE_ALL"
            case let .business(team):
                return team.anonymousTeamId
        }
    }
}

extension TeamSpacesService {
    var currentIdentityDashboardSpaceId: String? {
        return hasBusinessSpace ? selectedSpace.identityDashboardSpaceId : UserSpace.both.identityDashboardSpaceId
    }
}
