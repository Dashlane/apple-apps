import Foundation
import DashTypes

extension FetchRequest {
    init(request: SharingUpdater.UpdateRequest) {
        self.init(itemGroupIds: request.itemGroups.idsToFetch,
                  itemIds: request.items.idsToFetch,
                  userGroupIds: request.userGroups.idsToFetch)
    }
}

extension SharingClientAPI {
    func fetch(_ request: SharingUpdater.UpdateRequest) async throws -> ParsedServerResponse {
        try await fetch(FetchRequest(request: request))
    }
}

extension Logger {
    func log(_ response: ParsedServerResponse) {
        info("Received \(response.userGroups.count) item groups")
        for groupError in response.userGroupErrors {
            error("user group \(groupError.groupId): \(groupError.message)")
        }
        
        info("Received \(response.itemGroups.count) item groups")
        for groupError in response.itemGroupErrors {
            error("item group \(groupError.groupId): \(groupError.message)")
        }
        
        info("Received \(response.items.count) items")
        for itemError in response.itemErrors {
            error("item \(itemError.itemId): \(itemError.message)")
        }
    }
}
