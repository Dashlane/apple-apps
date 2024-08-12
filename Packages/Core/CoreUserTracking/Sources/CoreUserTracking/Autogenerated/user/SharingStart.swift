import Foundation

extension UserEvent {

  public struct `SharingStart`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(
      `collectionId`: String? = nil, `itemId`: String? = nil, `origin`: Definition.Origin,
      `sharingFlowType`: Definition.SharingFlowType
    ) {
      self.collectionId = collectionId
      self.itemId = itemId
      self.origin = origin
      self.sharingFlowType = sharingFlowType
    }
    public let collectionId: String?
    public let itemId: String?
    public let name = "sharing_start"
    public let origin: Definition.Origin
    public let sharingFlowType: Definition.SharingFlowType
  }
}
