import Combine
import DashTypes
import Foundation

extension ApplicationDBStack {
  public func fetchAll<Output: PersonalDataCodable>(_ type: Output.Type, ignoreDecodingErrors: Bool)
    throws -> [Output]
  {
    let records = try driver.read {
      try $0.fetchAll(by: type.contentType)
    }.filter { $0.metadata.syncStatus != .pendingRemove }

    return try decode(type, from: records, ignoreDecodingErrors: ignoreDecodingErrors)
  }

  public func fetch<Output>(with id: Identifier, type: Output.Type) throws -> Output?
  where Output: PersonalDataCodable {
    let item = try driver.read {
      try $0.fetchOne(with: id)
    }.map {
      try decode(Output.self, from: $0)
    }

    guard item?.metadata.syncStatus != .pendingRemove else {
      return nil
    }

    return item
  }

  public func fetchAll<Output>(
    with ids: [Identifier], type: Output.Type, ignoreDecodingErrors: Bool
  ) throws -> [Output] where Output: PersonalDataCodable {
    let records = try driver.read {
      try $0.fetchAll(with: ids)
    }.filter { $0.metadata.syncStatus != .pendingRemove }

    return try decode(Output.self, from: records, ignoreDecodingErrors: ignoreDecodingErrors)
  }

  public func count<Item: PersonalDataCodable>(for item: Item.Type) throws -> Int {
    return try driver.read {
      try $0.count(for: item.contentType)
    }
  }

  public func itemsPublisher<Output: PersonalDataCodable>(for output: Output.Type)
    -> PersonalDataPublisher<Output>
  {
    return PersonalDataPublisher(output: output, stack: self)
  }

  public func fetchedPersonalData<Output: PersonalDataCodable>(for output: Output.Type)
    -> FetchedPersonalData<Output>
  {
    return FetchedPersonalData(stack: self)
  }

  public func itemPublisher<Output: PersonalDataCodable>(for id: Identifier, type: Output.Type)
    -> AnyPublisher<Output, Error>
  {
    return
      driver
      .publisher(with: id)
      .compactMap { record in
        guard let record = record, record.metadata.syncStatus != .pendingRemove else {
          return nil
        }
        do {
          return try decode(Output.self, from: record)
        } catch {
          logger.fatal("Cannot decode type \(Output.self)", error: error)
          return nil
        }
      }
      .eraseToAnyPublisher()
  }

  public func itemPublisher<Output: PersonalDataCodable>(
    withParentId id: Identifier, type: Output.Type
  ) -> AnyPublisher<Output?, Error> {
    return
      driver
      .publisher(withParentId: id)
      .map { record in
        guard let record = record, record.metadata.syncStatus != .pendingRemove else {
          return nil
        }
        do {
          return try decode(Output.self, from: record)
        } catch {
          logger.fatal("Cannot decode type \(Output.self)", error: error)
          return nil
        }
      }
      .eraseToAnyPublisher()
  }

  public func metadataPublisher(for id: Identifier) -> AnyPublisher<RecordMetadata, Error> {
    return
      driver
      .metadataPublisher(with: id)
      .compactMap { metadata in
        guard let metadata = metadata, metadata.syncStatus != .pendingRemove else {
          return nil
        }

        return metadata
      }
      .eraseToAnyPublisher()
  }

  public func sharedItem(for id: Identifier) throws -> PersonalDataCodable? {
    return try driver.read { db -> (PersonalDataRecord, SharingType)? in
      guard let record = try db.fetchOne(with: id),
        let sharingType = record.metadata.contentType.sharingType,
        record.metadata.syncStatus != .pendingRemove
      else {
        return nil
      }

      return (record, sharingType)
    }.map { (record, sharingType) in
      try decoder.decode(sharingType, from: record, using: makeLinkedFetcher())
    }
  }
}
