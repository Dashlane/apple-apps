import Foundation

public struct BusinessTeam: Equatable, Hashable {
        public let space: Space

        public let anonymousTeamId: String

    public init(space: Space, anonymousTeamId: String) {
        self.space = space
        self.anonymousTeamId = anonymousTeamId
    }
}

extension BusinessTeam {
        public var shouldForceSpace: Bool {
        return space.info.forcedDomainsEnabled == true
    }

        public var shouldDeleteForcedItemsOnRevoke: Bool {
        return shouldForceSpace && space.info.removeForcedContentEnabled == true
    }

        public var hasServerAskedToDelete: Bool {
        return space.shouldDelete == true
    }

        public var shouldDisplayItemsInPersonalSpace: Bool {
        return space.status == .revoked && !shouldDeleteForcedItemsOnRevoke && !shouldForceSpace
    }

    public var teamId: String {
        return space.teamId
    }

        public func isValueMatchingDomains(_ value: String) -> Bool {
        let domains = space.info.teamDomains ?? []
        let value = value.lowercased()
        return domains.contains {
            value.contains($0)
        }
    }
}
