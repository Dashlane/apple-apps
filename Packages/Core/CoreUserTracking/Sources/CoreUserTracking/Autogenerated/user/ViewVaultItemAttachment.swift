import Foundation

extension UserEvent {

  public struct `ViewVaultItemAttachment`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(
      `itemId`: String, `itemSource`: Definition.ItemSource? = nil, `itemType`: Definition.ItemType
    ) {
      self.itemId = itemId
      self.itemSource = itemSource
      self.itemType = itemType
    }
    public let itemId: String
    public let itemSource: Definition.ItemSource?
    public let itemType: Definition.ItemType
    public let name = "view_vault_item_attachment"
  }
}
