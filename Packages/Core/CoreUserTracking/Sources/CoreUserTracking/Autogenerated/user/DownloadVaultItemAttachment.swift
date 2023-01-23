import Foundation

extension UserEvent {

public struct `DownloadVaultItemAttachment`: Encodable, UserEventProtocol {
public static let isPriority = false
public init(`itemId`: String, `itemType`: Definition.ItemType) {
self.itemId = itemId
self.itemType = itemType
}
public let itemId: String
public let itemType: Definition.ItemType
public let name = "download_vault_item_attachment"
}
}
