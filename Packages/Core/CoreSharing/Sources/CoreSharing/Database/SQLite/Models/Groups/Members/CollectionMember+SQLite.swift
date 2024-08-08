import GRDB

extension CollectionMember: TableRecord, FetchableRecord, PersistableRecord {
  static let collection = belongsTo(CollectionInfo.self, using: ForeignKey([Column.id]))
}
