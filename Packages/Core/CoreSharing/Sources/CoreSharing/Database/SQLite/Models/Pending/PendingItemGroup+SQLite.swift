import CoreTypes
import Foundation
import GRDB

extension PendingItemGroup: FetchableRecord {}

extension PendingItemGroup: Decodable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.itemGroupInfo = try container.decode(ItemGroupInfo.self, forKey: .itemGroupInfo)
    self.itemIds = try container.decode(Set<Identifier>.self, forKey: .itemIds)
    self.referrer = try container.decode([String].self, forKey: .referrer).first
  }
}
