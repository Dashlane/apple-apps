import Foundation

extension UserEvent {

  public struct `OpenVaultItemDropdown`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(
      `dropdownType`: Definition.DropdownType, `highlight`: Definition.Highlight? = nil,
      `index`: Double? = nil,
      `itemType`: Definition.ItemType, `totalCount`: Int? = nil
    ) {
      self.dropdownType = dropdownType
      self.highlight = highlight
      self.index = index
      self.itemType = itemType
      self.totalCount = totalCount
    }
    public let dropdownType: Definition.DropdownType
    public let highlight: Definition.Highlight?
    public let index: Double?
    public let itemType: Definition.ItemType
    public let name = "open_vault_item_dropdown"
    public let totalCount: Int?
  }
}
