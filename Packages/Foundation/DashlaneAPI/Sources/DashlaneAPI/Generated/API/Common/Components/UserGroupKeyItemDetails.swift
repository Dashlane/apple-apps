import Foundation

public struct UserGroupKeyItemDetails: Codable, Hashable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case itemId = "itemId"
    case itemGroupRevision = "itemGroupRevision"
  }

  public let itemId: String
  public let itemGroupRevision: Int

  public init(itemId: String, itemGroupRevision: Int) {
    self.itemId = itemId
    self.itemGroupRevision = itemGroupRevision
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(itemId, forKey: .itemId)
    try container.encode(itemGroupRevision, forKey: .itemGroupRevision)
  }
}
