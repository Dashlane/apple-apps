import Foundation

extension UserEvent {

  public struct `UseVaultItem`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(
      `action`: Definition.Action, `fieldsUsed`: [Definition.Field], `itemId`: String,
      `itemSource`: Definition.ItemSource? = nil, `itemType`: Definition.ItemType
    ) {
      self.action = action
      self.fieldsUsed = fieldsUsed
      self.itemId = itemId
      self.itemSource = itemSource
      self.itemType = itemType
    }
    public let action: Definition.Action
    public let fieldsUsed: [Definition.Field]
    public let itemId: String
    public let itemSource: Definition.ItemSource?
    public let itemType: Definition.ItemType
    public let name = "use_vault_item"
  }
}
