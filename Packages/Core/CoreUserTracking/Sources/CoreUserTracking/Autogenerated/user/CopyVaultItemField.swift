import Foundation

extension UserEvent {

  public struct `CopyVaultItemField`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(
      `field`: Definition.Field, `highlight`: Definition.Highlight? = nil, `index`: Double? = nil,
      `isProtected`: Bool, `itemId`: String, `itemSource`: Definition.ItemSource? = nil,
      `itemType`: Definition.ItemType, `totalCount`: Int? = nil
    ) {
      self.field = field
      self.highlight = highlight
      self.index = index
      self.isProtected = isProtected
      self.itemId = itemId
      self.itemSource = itemSource
      self.itemType = itemType
      self.totalCount = totalCount
    }
    public let field: Definition.Field
    public let highlight: Definition.Highlight?
    public let index: Double?
    public let isProtected: Bool
    public let itemId: String
    public let itemSource: Definition.ItemSource?
    public let itemType: Definition.ItemType
    public let name = "copy_vault_item_field"
    public let totalCount: Int?
  }
}
