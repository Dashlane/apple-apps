import Foundation

extension UserEvent {

public struct `FilterByCollection`: Encodable, UserEventProtocol {
public static let isPriority = false
public init(`collectionCount`: Int, `hasInteracted`: Bool, `isFromSearch`: Bool, `totalCount`: Int) {
self.collectionCount = collectionCount
self.hasInteracted = hasInteracted
self.isFromSearch = isFromSearch
self.totalCount = totalCount
}
public let collectionCount: Int
public let hasInteracted: Bool
public let isFromSearch: Bool
public let name = "filter_by_collection"
public let totalCount: Int
}
}
