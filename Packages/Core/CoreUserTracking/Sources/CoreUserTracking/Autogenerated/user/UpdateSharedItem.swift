import Foundation

extension UserEvent {

  public struct `UpdateSharedItem`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(
      `itemType`: Definition.SharingItemType, `rights`: Definition.Rights,
      `updateStatus`: Definition.UpdateStatus
    ) {
      self.itemType = itemType
      self.rights = rights
      self.updateStatus = updateStatus
    }
    public let itemType: Definition.SharingItemType
    public let name = "update_shared_item"
    public let rights: Definition.Rights
    public let updateStatus: Definition.UpdateStatus
  }
}
