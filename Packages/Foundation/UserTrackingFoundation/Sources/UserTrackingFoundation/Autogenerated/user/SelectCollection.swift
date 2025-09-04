import Foundation

extension UserEvent {

  public struct `SelectCollection`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(`collectionId`: String, `collectionSelectOrigin`: Definition.CollectionSelectOrigin)
    {
      self.collectionId = collectionId
      self.collectionSelectOrigin = collectionSelectOrigin
    }
    public let collectionId: String
    public let collectionSelectOrigin: Definition.CollectionSelectOrigin
    public let name = "select_collection"
  }
}
