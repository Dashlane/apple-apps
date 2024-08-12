import Combine
import DashTypes
import Foundation

public protocol ApplicationDatabase {
  func fetchAll<Output: PersonalDataCodable>(_ type: Output.Type, ignoreDecodingErrors: Bool) throws
    -> [Output]

  func fetch<Output: PersonalDataCodable>(with id: Identifier, type: Output.Type) throws -> Output?

  func fetchAll<Output: PersonalDataCodable>(
    with ids: [Identifier], type: Output.Type, ignoreDecodingErrors: Bool
  ) throws -> [Output]

  func count<Item: PersonalDataCodable>(for item: Item.Type) throws -> Int

  func itemsPublisher<Output: PersonalDataCodable>(for output: Output.Type)
    -> PersonalDataPublisher<Output>

  func fetchedPersonalData<Output: PersonalDataCodable>(for output: Output.Type)
    -> FetchedPersonalData<Output>

  func itemPublisher<Output: PersonalDataCodable>(for id: Identifier, type: Output.Type)
    -> AnyPublisher<Output, Error>

  func metadataPublisher(for id: Identifier) -> AnyPublisher<RecordMetadata, Error>

  func delete(_ data: PersonalDataCodable) throws
  func delete(_ data: [PersonalDataCodable]) throws

  @discardableResult
  func save<T: PersonalDataCodable>(_ item: T) throws -> T

  @discardableResult
  func save<T: PersonalDataCodable>(_ items: [T]) throws -> [T]

  @discardableResult
  func save<T: PersonalDataCodable & DatedPersonalData>(_ item: T) throws -> T

  func updateLastUseDate(for ids: [Identifier], origin: Set<LastUseUpdateOrigin>) throws

  func sharedItem(for id: Identifier) throws -> PersonalDataCodable?

  func changeSetsPublisher<T: HistoryChangeTracking>(for item: T) -> ChangeSetPublisher<T>

  func revert<T: HistoryChangeTracking>(
    _ id: Identifier,
    to changeSet: PersonalDataChangeSet<T>) throws

  func checkShareability(of itemIds: [Identifier]) throws
}

public enum LastUseUpdateOrigin: Hashable {
  case `default`
  case search
}

extension ApplicationDatabase {
  public func fetchAll<Output: PersonalDataCodable>(_ type: Output.Type) throws -> [Output] {
    try fetchAll(type, ignoreDecodingErrors: true)
  }

  public func fetchAll<Output: PersonalDataCodable>(with ids: [Identifier], type: Output.Type)
    throws -> [Output]
  {
    try fetchAll(with: ids, type: type, ignoreDecodingErrors: true)
  }
}
