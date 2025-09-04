import Foundation

extension AnonymousEvent {

  public struct `CopyVaultItemField`: Encodable, AnonymousEventProtocol {
    public static let isPriority = true
    public init(
      `domain`: Definition.Domain, `field`: Definition.Field, `itemType`: Definition.ItemType
    ) {
      self.domain = domain
      self.field = field
      self.itemType = itemType
    }
    public let domain: Definition.Domain
    public let field: Definition.Field
    public let itemType: Definition.ItemType
    public let name = "copy_vault_item_field"
  }
}
