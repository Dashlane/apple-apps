import DashTypes
import Foundation

extension SharingClientAPIImpl {

  public func fetch(_ request: FetchRequest) async throws -> ParsedServerResponse {
    var request = request
    var accumulatedResponse = ParsedServerResponse()
    while let request = request.nextGetBatchRequest() {
      accumulatedResponse += try await apiClient.get(
        collectionIds: request.collectionIds?.map(\.rawValue),
        itemGroupIds: request.itemGroupIds?.map(\.rawValue),
        itemIds: request.itemIds?.map(\.rawValue),
        userGroupIds: request.userGroupIds?.map(\.rawValue)
      ).parsed()
    }
    return accumulatedResponse
  }
}

extension FetchRequest {
  struct BatchRequest {
    let itemGroupIds: [Identifier]?
    let itemIds: [Identifier]?
    let userGroupIds: [Identifier]?
    let collectionIds: [Identifier]?
  }

  mutating func nextGetBatchRequest() -> BatchRequest? {
    guard !isEmpty else {
      return nil
    }

    let currentItemGroupIds = itemGroupIds.popLast()
    let currentItemIds = itemIds.popLast()
    let currentUserGroupIds = userGroupIds.popLast()
    let currentCollectionIds = collectionIds.popLast()

    return BatchRequest(
      itemGroupIds: currentItemGroupIds,
      itemIds: currentItemIds,
      userGroupIds: currentUserGroupIds,
      collectionIds: currentCollectionIds
    )
  }
}
