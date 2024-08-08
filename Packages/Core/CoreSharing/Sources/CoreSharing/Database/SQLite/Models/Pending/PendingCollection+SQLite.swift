import GRDB

extension PendingCollection: FetchableRecord {}

extension PendingCollection: Decodable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: PendingCollection.CodingKeys.self)
    self.collectionInfo = try container.decode(CollectionInfo.self, forKey: .collectionInfo)
    self.referrer = try container.decode([String].self, forKey: .referrer).first
  }
}
