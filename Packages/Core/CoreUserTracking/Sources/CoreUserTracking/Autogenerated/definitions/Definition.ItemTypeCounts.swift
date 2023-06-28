import Foundation

extension Definition {

public struct `ItemTypeCounts`: Encodable {
public init(`collectionsCount`: Int? = nil, `collectionsSharedCount`: Int? = nil, `multipleCollectionsCount`: Int? = nil, `multipleCollectionsSharedCount`: Int? = nil, `sharedCount`: Int? = nil, `singleCollectionCount`: Int? = nil, `singleCollectionSharedCount`: Int? = nil, `totalCount`: Int) {
self.collectionsCount = collectionsCount
self.collectionsSharedCount = collectionsSharedCount
self.multipleCollectionsCount = multipleCollectionsCount
self.multipleCollectionsSharedCount = multipleCollectionsSharedCount
self.sharedCount = sharedCount
self.singleCollectionCount = singleCollectionCount
self.singleCollectionSharedCount = singleCollectionSharedCount
self.totalCount = totalCount
}
public let collectionsCount: Int?
public let collectionsSharedCount: Int?
public let multipleCollectionsCount: Int?
public let multipleCollectionsSharedCount: Int?
public let sharedCount: Int?
public let singleCollectionCount: Int?
public let singleCollectionSharedCount: Int?
public let totalCount: Int
}
}