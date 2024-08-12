import CyrilKit
import DashTypes
import DashlaneAPI
import Foundation

public struct ItemContentCache: Codable, Identifiable, Hashable {
  enum CodingKeys: String, CodingKey {
    case id
    case timestamp
    case encryptedContent
  }
  public let id: Identifier
  public let timestamp: SharingTimestamp
  public let encryptedContent: String
}

extension ItemContentCache {
  init(_ item: ItemContent) {
    self.id = Identifier(item.itemId)
    self.timestamp = item.timestamp
    self.encryptedContent = item.content
  }
}
