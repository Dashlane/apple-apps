import Foundation

extension AnonymousEvent {

public struct `OpenExternalVaultItemLink`: Encodable, AnonymousEventProtocol {
public static let isPriority = false
public init(`domain`: Definition.Domain, `itemType`: Definition.ItemTypeWithLink) {
self.domain = domain
self.itemType = itemType
}
public let domain: Definition.Domain
public let itemType: Definition.ItemTypeWithLink
public let name = "open_external_vault_item_link"
}
}
