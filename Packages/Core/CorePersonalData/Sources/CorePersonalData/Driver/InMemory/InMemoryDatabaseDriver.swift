import Combine
import DashTypes
import Foundation

public struct InMemoryDatabaseDriver: DatabaseDriver {

  public class Store {
    @Published
    public var records: [Identifier: PersonalDataRecord] = [:]
    @Published
    public var snapshots: [Identifier: PersonalDataSnapshot] = [:]
  }

  public let eventPublisher = PassthroughSubject<DatabaseEvent, Never>()
  public let syncTriggerPublisher = PassthroughSubject<Void, Never>()
  public let store = Store()

  private let queue = DispatchQueue(label: "InMemoryDatabaseDriver")

  public init() {

  }

  public func read<T>(_ reader: (DatabaseReader) throws -> T) throws -> T {
    return try queue.sync { try reader(InMemoryDatabase(store: store)) }
  }

  public func write<T>(shouldSyncChange: Bool, _ writer: (inout DatabaseWriter) throws -> T) throws
    -> T
  {
    return try queue.sync {
      var database: DatabaseWriter = InMemoryDatabase(store: store)
      let result = try writer(&database)
      eventPublisher.send(.incrementalChanges(database.changes))
      if shouldSyncChange && database.changes.allSatisfy({ $0.kind != .metadataUpdated }) {
        syncTriggerPublisher.send()
      }
      return result
    }
  }

  public func publisher(with id: Identifier) -> AnyPublisher<PersonalDataRecord?, Error> {
    store.$records.map { records in
      return records[id]
    }
    .removeDuplicates()
    .setFailureType(to: Error.self)
    .eraseToAnyPublisher()
  }

  public func publisher(withParentId id: Identifier) -> AnyPublisher<PersonalDataRecord?, Error> {
    store.$records.compactMap { records in
      return records.first { $0.value.metadata.parentId == id }?.value
    }
    .removeDuplicates()
    .setFailureType(to: Error.self)
    .eraseToAnyPublisher()
  }

  public func metadataPublisher(with id: DashTypes.Identifier) -> AnyPublisher<
    RecordMetadata?, Error
  > {
    publisher(with: id).map { $0?.metadata }.eraseToAnyPublisher()
  }
}

struct InMemoryDatabase {
  let store: InMemoryDatabaseDriver.Store
  public var changes: Set<DatabaseChange> = []
}
