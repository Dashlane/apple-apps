import Foundation

public struct BusinessTeamsInfo {
        public let businessTeams: [BusinessTeam]

        public let availableBusinessTeam: BusinessTeam?

    public init(businessTeams: [BusinessTeam]) {
        self.businessTeams = businessTeams
        self.availableBusinessTeam = businessTeams.first { $0.space.status == .accepted }
    }
}

public extension BusinessTeamsInfo {
            func userSpace(forSpaceId spaceId: String?) -> UserSpace? {
        guard let spaceId = spaceId, !spaceId.isEmpty else {
            return  .personal
        }
        if let team = availableBusinessTeam, team.teamId == spaceId {
            return .business(team)
        } else if businessTeams.contains(where: { $0.shouldDisplayItemsInPersonalSpace && $0.teamId == spaceId }) {
            return .personal
        } else if !businessTeams.contains(where: { $0.teamId == spaceId }) {
                        return .personal
        } else {
            return nil
        }
    }
}

public extension BusinessTeamsInfo {
    func isSharingDisabled() -> Bool {
        guard let sharingDisabled = availableBusinessTeam?.space.info.sharingDisabled else {
            return false
        }
        return sharingDisabled
    }
}
