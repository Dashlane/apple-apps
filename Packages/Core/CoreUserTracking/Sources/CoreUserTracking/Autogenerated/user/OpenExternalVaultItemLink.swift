import Foundation

extension UserEvent {

public struct `OpenExternalVaultItemLink`: Encodable, UserEventProtocol {
public static let isPriority = false
public init(`domainType`: Definition.DomainType, `itemId`: String, `itemType`: Definition.ItemTypeWithLink) {
self.domainType = domainType
self.itemId = itemId
self.itemType = itemType
}
public let domainType: Definition.DomainType
public let itemId: String
public let itemType: Definition.ItemTypeWithLink
public let name = "open_external_vault_item_link"
}
}
