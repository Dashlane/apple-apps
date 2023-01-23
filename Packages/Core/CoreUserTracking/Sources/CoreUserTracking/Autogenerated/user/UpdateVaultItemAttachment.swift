import Foundation

extension UserEvent {

public struct `UpdateVaultItemAttachment`: Encodable, UserEventProtocol {
public static let isPriority = false
public init(`attachmentAction`: Definition.Action, `itemId`: String, `itemType`: Definition.ItemType) {
self.attachmentAction = attachmentAction
self.itemId = itemId
self.itemType = itemType
}
public let attachmentAction: Definition.Action
public let itemId: String
public let itemType: Definition.ItemType
public let name = "update_vault_item_attachment"
}
}
