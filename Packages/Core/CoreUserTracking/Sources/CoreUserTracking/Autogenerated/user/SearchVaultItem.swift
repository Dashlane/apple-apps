import Foundation

extension UserEvent {

public struct `SearchVaultItem`: Encodable, UserEventProtocol {
public static let isPriority = false
public init(`charactersTypedCount`: Int, `hasInteracted`: Bool, `highlight`: Definition.Highlight? = nil, `totalCount`: Int) {
self.charactersTypedCount = charactersTypedCount
self.hasInteracted = hasInteracted
self.highlight = highlight
self.totalCount = totalCount
}
public let charactersTypedCount: Int
public let hasInteracted: Bool
public let highlight: Definition.Highlight?
public let name = "search_vault_item"
public let totalCount: Int
}
}
