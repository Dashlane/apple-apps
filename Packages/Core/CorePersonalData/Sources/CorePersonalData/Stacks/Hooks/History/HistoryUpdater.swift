import DashTypes
import Foundation

struct HistoryUpdater {
  private enum Operation {
    case update(newRecord: PersonalDataRecord)
    case delete
  }

  typealias ChangeSet = DataChangeHistory.ChangeSet

  let info: HistoryUserInfo
  let decoder = PersonalDataDecoder()
  let encoder = PersonalDataEncoder()

  private func updateIfNeeded(
    for operation: Operation,
    previousRecord: PersonalDataRecord,
    in db: inout DatabaseWriter
  ) throws {
    let versionableKeys = previousRecord.metadata.contentType.triggerHistoryKeys
    guard !versionableKeys.isEmpty else {
      return
    }

    let historyRecord = try db.fetchOne(withParentId: previousRecord.id)

    var history: DataChangeHistory
    if let historyRecord = historyRecord,
      let decodedHistory = try decode(historyRecord)
    {
      history = decodedHistory
    } else {
      history = makeDataChangeHistory(record: previousRecord)
    }

    switch operation {
    case let .update(newRecord):
      let changedKeys = Set(
        newRecord.content.keys.filter {
          newRecord.content[$0] != previousRecord.content[$0]
        }
      ).intersection(versionableKeys)

      guard !changedKeys.isEmpty else {
        return
      }

      history.objectTitle = newRecord.historyTitle
      let changeSet = makeChangeSet(previousRecord: previousRecord, changedKeys: changedKeys)
      history.changeSets.append(changeSet)

    case .delete:
      guard let deleteChangeSet = makeDeleteChangeSet(deletedRecord: previousRecord) else {
        return
      }

      history.objectTitle = previousRecord.historyTitle
      history.changeSets.append(deleteChangeSet)
    }

    var metadata = history.metadata
    metadata.markAsPendingUpload()
    let content = try encoder.encode(history, in: historyRecord?.content ?? [:])
    try db.save(PersonalDataRecord(metadata: metadata, content: content))
  }

  func updateIfNeeded(
    forNewRecord newRecord: PersonalDataRecord,
    previousRecord: PersonalDataRecord,
    in db: inout DatabaseWriter
  ) throws {
    try updateIfNeeded(for: .update(newRecord: newRecord), previousRecord: previousRecord, in: &db)
  }

  func updateIfNeeded(
    forDeletedRecord deletedRecord: PersonalDataRecord, in db: inout DatabaseWriter
  ) throws {
    try updateIfNeeded(for: .delete, previousRecord: deletedRecord, in: &db)
  }

  func updateIfNeeded(
    forDeletedItem personalDataCodable: PersonalDataCodable, in db: inout DatabaseWriter
  ) throws {
    guard !personalDataCodable.metadata.contentType.triggerHistoryKeys.isEmpty,
      let deletedRecord = try db.fetchOne(with: personalDataCodable.id)
    else {
      return
    }

    try updateIfNeeded(for: .delete, previousRecord: deletedRecord, in: &db)
  }
}

extension HistoryUpdater {
  func decode(_ historyRecord: PersonalDataRecord) throws -> DataChangeHistory? {
    guard historyRecord.metadata.contentType == .dataChangeHistory else {
      return nil
    }

    return try decoder.decode(DataChangeHistory.self, from: historyRecord)
  }

  func makeDataChangeHistory(record: PersonalDataRecord) -> DataChangeHistory {
    let metadata = RecordMetadata(
      id: Identifier(),
      contentType: .dataChangeHistory,
      syncStatus: .pendingUpload,
      parentId: record.id)

    return DataChangeHistory(
      id: metadata.id,
      objectId: record.metadata.id,
      objectTitle: record.historyTitle,
      objectType: record.metadata.contentType,
      metadata: metadata,
      changeSets: [])
  }

  func makeChangeSet(previousRecord: PersonalDataRecord, changedKeys: Set<String>) -> ChangeSet {
    DataChangeHistory.ChangeSet(
      id: .init(),
      changedKeys: Set(changedKeys.map { $0.capitalizingFirstLetter() }),
      previousRecordContent: previousRecord.content.filter { changedKeys.contains($0.key) },
      modificationDate: Date(),
      removed: false,
      platform: info.platform,
      deviceName: info.deviceName,
      user: info.user)
  }

  func makeDeleteChangeSet(deletedRecord: PersonalDataRecord) -> ChangeSet? {
    let versionableKeys = deletedRecord.metadata.contentType.triggerHistoryKeys
    guard !versionableKeys.isEmpty else {
      return nil
    }

    return DataChangeHistory.ChangeSet(
      id: .init(),
      changedKeys: Set(),
      previousRecordContent: deletedRecord.content.filter { versionableKeys.contains($0.key) },
      modificationDate: Date(),
      removed: true,
      platform: info.platform,
      deviceName: info.deviceName,
      user: info.user)
  }
}

extension PersonalDataRecord {
  fileprivate var historyTitle: String? {
    guard let key = metadata.contentType.historyTitleKey else {
      return nil
    }

    return content[key]?.item
  }
}
