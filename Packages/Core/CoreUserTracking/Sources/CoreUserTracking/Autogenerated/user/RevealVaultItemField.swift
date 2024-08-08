import Foundation

extension UserEvent {

  public struct `RevealVaultItemField`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(
      `field`: Definition.Field, `isProtected`: Bool, `itemId`: String,
      `itemSource`: Definition.ItemSource? = nil, `itemType`: Definition.ItemType
    ) {
      self.field = field
      self.isProtected = isProtected
      self.itemId = itemId
      self.itemSource = itemSource
      self.itemType = itemType
    }
    public let field: Definition.Field
    public let isProtected: Bool
    public let itemId: String
    public let itemSource: Definition.ItemSource?
    public let itemType: Definition.ItemType
    public let name = "reveal_vault_item_field"
  }
}
