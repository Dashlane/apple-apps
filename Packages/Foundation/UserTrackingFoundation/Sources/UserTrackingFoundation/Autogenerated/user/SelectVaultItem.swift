import Foundation

extension UserEvent {

  public struct `SelectVaultItem`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(
      `highlight`: Definition.Highlight, `index`: Double? = nil, `itemId`: String,
      `itemSource`: Definition.ItemSource? = nil, `itemType`: Definition.ItemType,
      `totalCount`: Int? = nil
    ) {
      self.highlight = highlight
      self.index = index
      self.itemId = itemId
      self.itemSource = itemSource
      self.itemType = itemType
      self.totalCount = totalCount
    }
    public let highlight: Definition.Highlight
    public let index: Double?
    public let itemId: String
    public let itemSource: Definition.ItemSource?
    public let itemType: Definition.ItemType
    public let name = "select_vault_item"
    public let totalCount: Int?
  }
}
