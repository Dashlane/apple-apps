import CoreTypes
import Foundation

extension ApplicationDBStack {
  public func delete(_ data: PersonalDataCodable) throws {
    try delete([data])
  }

  public func delete(_ data: [PersonalDataCodable]) throws {
    try driver.write { db in
      try db.updateSyncStatus(.pendingRemove, for: data.map(\.metadata.id))
      for item in data {
        try historyUpdater.updateIfNeeded(forDeletedItem: item, in: &db)
      }
    }
  }
}

extension ApplicationDBStack {
  @discardableResult
  public func save<T: PersonalDataCodable>(_ item: T) throws -> T {
    var item = item
    return try performSave(&item)
  }

  @discardableResult
  public func save<T: PersonalDataCodable>(_ items: [T]) throws -> [T] {
    try driver.write { db in
      try items.forEach { item in
        var item = item
        if item.isSaved {
          try update(&item, in: &db)
        } else {
          try insert(&item, in: &db)
        }
      }
    }
    return try fetchAll(with: items.map(\.id), type: T.self)
  }

  private func performSave<T: PersonalDataCodable>(_ item: inout T) throws -> T {
    try driver.write { db in
      if item.isSaved {
        try update(&item, in: &db)
      } else {
        try insert(&item, in: &db)
      }
    }
    return try fetch(with: item.id, type: T.self) ?? item
  }

  private func makeRecord<T: PersonalDataCodable>(
    metadata: RecordMetadata,
    existingCotent: PersonalDataCollection = [:],
    item: inout T
  ) throws -> PersonalDataRecord {
    var metadata = metadata
    metadata.markAsPendingUpload()
    metadata.lastLocalUseDate = item.isSaved ? Date() : nil

    try item.prepareForSavingAndValidate()
    let content = try encoder.encode(item, in: existingCotent)

    sharingUploadTrigger.update(&metadata, for: content, oldContent: existingCotent)

    return PersonalDataRecord(
      metadata: metadata,
      content: content)
  }

  private func insert<T: PersonalDataCodable>(_ item: inout T, in db: inout DatabaseWriter) throws {
    var metadata = item.metadata
    metadata.id = item.id
    let record = try makeRecord(metadata: metadata, item: &item)

    try db.insert(record)
  }

  private func update<T: PersonalDataCodable>(_ item: inout T, in db: inout DatabaseWriter) throws {
    guard let record = try db.fetchOne(with: item.metadata.id) else {
      return
    }
    let updatedRecord = try makeRecord(
      metadata: record.metadata,
      existingCotent: record.content,
      item: &item)

    try db.update(updatedRecord)
    try historyUpdater.updateIfNeeded(
      forNewRecord: updatedRecord,
      previousRecord: record,
      in: &db)
  }
}

extension ApplicationDBStack {
  public func updateLastUseDate(for ids: [Identifier], origin: Set<LastUseUpdateOrigin>) throws {
    guard !origin.isEmpty else {
      return
    }

    let date = Date()
    try driver.write(shouldSyncChange: false) { db in
      for id in ids {
        guard var metadata = try db.fetchOneMetadata(with: id) else {
          return
        }
        if origin.contains(.default) {
          metadata.lastLocalUseDate = date
        }
        if origin.contains(.search) {
          metadata.lastLocalSearchDate = date
        }
        try db.update(metadata)
      }
    }
  }

  @discardableResult
  public func save<T: PersonalDataCodable & DatedPersonalData>(_ item: T) throws -> T {
    var item = item
    let now = Date()
    item.userModificationDatetime = now
    if !item.isSaved {
      item.creationDatetime = now
    }

    return try performSave(&item)
  }
}
