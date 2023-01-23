import Foundation
import CorePersonalData
import CorePremium
import DashTypes
import CoreNetworking
import Combine
import DashlaneAppKit
import VaultKit

struct TeamSpacesRevokeHandler {
    let database: ApplicationDatabase
    let networkEngine: LegacyWebService
    let sharingService: SharedVaultHandling
    let logger: Logger

    internal init(database: ApplicationDatabase,
                  networkEngine: LegacyWebService,
                  sharingService: SharedVaultHandling,
                  logger: Logger) {
        self.database = database
        self.networkEngine = networkEngine
        self.sharingService = sharingService
        self.logger = logger
    }

    func updateVaultForRevokedBusinessTeam(_ businessTeam: BusinessTeam) -> AnyPublisher<BusinessTeam, Error> {
        do {
                        let emails = try database.fetchAll(Email.self, in: businessTeam)
            try database.moveToPersonalSpace(emails)

                        let credentials = try database.fetchAll(Credential.self, in: businessTeam)
            if businessTeam.shouldForceSpace {
                if businessTeam.shouldDeleteForcedItemsOnRevoke {
                    let forcedSpaceCredentials = credentials.filter {
                        $0.isAssociated(to: businessTeam)
                    }

                    return Future {
                        try await sharingService.forceRevoke(forcedSpaceCredentials)
                    }.tryMap {
                                                let credentials = try self.database.fetchAll(Credential.self, in: businessTeam)

                                                                        let credentialsBySpaceForcedState = credentials.splitByForcedSpace(in: businessTeam)

                        try self.database.moveToPersonalSpace(credentialsBySpaceForcedState[.notForced, default: []])

                        if businessTeam.hasServerAskedToDelete {
                            try self.database.delete(credentialsBySpaceForcedState[.forced, default: []])
                            self.notifyDelete(for: businessTeam)
                        }
                    } .map { return businessTeam }.eraseToAnyPublisher()

                } else {
                                        return Just(businessTeam).setFailureType(to: Error.self).eraseToAnyPublisher()
                }
            } else {
                                try self.database.moveToPersonalSpace(credentials)

                return Just(businessTeam).setFailureType(to: Error.self).eraseToAnyPublisher()
            }

        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }

}

extension ApplicationDatabase {
    public func moveToPersonalSpace<Item: VaultItem & PersonalDataCodable>(_ items: [Item]) throws {
        let movedItems: [Item] = items.map { item in
            var movedItem = item
            movedItem.spaceId = UserSpace.personal.personalDataId
            return movedItem
        }
        try save(movedItems)
    }

    public func fetchAll<Item: VaultItem & PersonalDataCodable>(_ type: Item.Type, in businessTeam: BusinessTeam) throws -> [Item] {
        return try fetchAll(type).filter { $0.spaceId == businessTeam.teamId }
    }
}

extension TeamSpacesRevokeHandler: ResponseParserProtocol {
    private func notifyDelete(for businessTeam: BusinessTeam) {
        let requestParams = [ "teamId": businessTeam.teamId]
        networkEngine.sendRequest(
            to: "/1/teamPlans/spaceDeleted",
            using: .post,
            params: requestParams,
            contentFormat: .queryString, needsAuthentication: true,
            responseParser: self) { _ in

        }
    }

    public func parse(data: Data) throws {
        return
    }
}

enum ForceSpaceState {
   case forced
   case notForced
}

extension Collection where Element: VaultItem {
    func splitByForcedSpace(in businessTeam: BusinessTeam) -> [ForceSpaceState: [Element]] {
        return Dictionary(grouping: self) {
           return $0.isAssociated(to: businessTeam) ? .forced : .notForced
        }
    }
}
