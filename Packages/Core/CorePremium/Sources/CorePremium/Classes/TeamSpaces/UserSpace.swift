import Foundation

public enum UserSpace: Hashable {
    case personal
    case business(BusinessTeam)
    case both

    public var anonymousIdForUsageLogs: String {
        switch self {
        case .personal:
            return "ID_DEFAULT"
        case .both:
            return "ID_ALL"
        case let .business(business):
            return business.anonymousTeamId
        }
    }

        public var personalDataId: String {
        switch self {
        case .personal, .both:
            return ""
        case let .business(space):
            return space.space.teamId
        }
    }
}

public extension UserSpace {
    func match(_ userSpace: UserSpace) -> Bool {
        switch userSpace {
            case .personal, .business:
                return  self == userSpace
            case .both:
                return true
        }
    }
}

extension UserSpace: Identifiable {
    public var id: String {
        return personalDataId
    }
}
