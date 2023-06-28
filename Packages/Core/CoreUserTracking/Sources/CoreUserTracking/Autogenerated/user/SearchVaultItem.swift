import Foundation

extension UserEvent {

public struct `SearchVaultItem`: Encodable, UserEventProtocol {
public static let isPriority = false
public init(`charactersTypedCount`: Int, `collectionCount`: Int? = nil, `hasClickedCollection`: Bool? = nil, `hasInteracted`: Bool, `highlight`: Definition.Highlight? = nil, `totalCount`: Int) {
self.charactersTypedCount = charactersTypedCount
self.collectionCount = collectionCount
self.hasClickedCollection = hasClickedCollection
self.hasInteracted = hasInteracted
self.highlight = highlight
self.totalCount = totalCount
}
public let charactersTypedCount: Int
public let collectionCount: Int?
public let hasClickedCollection: Bool?
public let hasInteracted: Bool
public let highlight: Definition.Highlight?
public let name = "search_vault_item"
public let totalCount: Int
}
}
