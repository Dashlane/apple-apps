import Foundation

extension UserEvent {

  public struct `SharingOutcome`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(
      `collectionId`: String? = nil, `isSuccessful`: Bool, `itemId`: String? = nil,
      `origin`: Definition.Origin,
      `sharingFlowType`: Definition.SharingFlowType
    ) {
      self.collectionId = collectionId
      self.isSuccessful = isSuccessful
      self.itemId = itemId
      self.origin = origin
      self.sharingFlowType = sharingFlowType
    }
    public let collectionId: String?
    public let isSuccessful: Bool
    public let itemId: String?
    public let name = "sharing_outcome"
    public let origin: Definition.Origin
    public let sharingFlowType: Definition.SharingFlowType
  }
}
