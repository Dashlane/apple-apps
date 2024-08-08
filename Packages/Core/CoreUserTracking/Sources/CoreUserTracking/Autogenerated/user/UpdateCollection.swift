import Foundation

extension UserEvent {

  public struct `UpdateCollection`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(
      `action`: Definition.CollectionAction, `collectionId`: String, `isShared`: Bool,
      `itemCount`: Int
    ) {
      self.action = action
      self.collectionId = collectionId
      self.isShared = isShared
      self.itemCount = itemCount
    }
    public let action: Definition.CollectionAction
    public let collectionId: String
    public let isShared: Bool
    public let itemCount: Int
    public let name = "update_collection"
  }
}
