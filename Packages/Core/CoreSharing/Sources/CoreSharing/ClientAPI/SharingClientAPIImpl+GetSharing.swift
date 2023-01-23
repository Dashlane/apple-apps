import Foundation
import DashTypes

extension SharingClientAPIImpl {

        public func fetch(_ request: FetchRequest) async throws -> ParsedServerResponse {
        var request = request
        var accumulatedResponse = ParsedServerResponse()
        while let request = request.nextGetBatchRequest() {
            let response = try await apiClient.get(itemGroupIds: request.itemGroupIds?.map(\.rawValue),
                                                   itemIds: request.itemIds?.map(\.rawValue),
                                                   userGroupIds: request.userGroupIds?.map(\.rawValue)).parsed()
            accumulatedResponse += response
        }
        return accumulatedResponse
    }
}


extension FetchRequest {
    struct BatchRequest {
        let itemGroupIds: [Identifier]?
        let itemIds: [Identifier]?
        let userGroupIds: [Identifier]?
    }

    mutating func nextGetBatchRequest() -> BatchRequest? {
        guard !isEmpty else {
            return nil
        }
        
        let currentItemGroupIds = itemGroupIds.popLast()
        let currentItemIds = itemIds.popLast()
        let currentUserGroupIds = userGroupIds.popLast()
        
        return BatchRequest(itemGroupIds: currentItemGroupIds,
                            itemIds: currentItemIds,
                            userGroupIds: currentUserGroupIds)
    }
}
