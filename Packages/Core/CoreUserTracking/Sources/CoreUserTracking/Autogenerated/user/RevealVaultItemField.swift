import Foundation

extension UserEvent {

public struct `RevealVaultItemField`: Encodable, UserEventProtocol {
public static let isPriority = false
public init(`field`: Definition.Field, `isProtected`: Bool, `itemId`: String, `itemType`: Definition.ItemType) {
self.field = field
self.isProtected = isProtected
self.itemId = itemId
self.itemType = itemType
}
public let field: Definition.Field
public let isProtected: Bool
public let itemId: String
public let itemType: Definition.ItemType
public let name = "reveal_vault_item_field"
}
}
