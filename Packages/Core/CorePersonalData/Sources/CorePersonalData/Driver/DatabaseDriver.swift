import Combine
import CoreTypes
import Foundation

public protocol DatabaseDriver {
  var eventPublisher: PassthroughSubject<DatabaseEvent, Never> { get }
  var syncTriggerPublisher: PassthroughSubject<Void, Never> { get }

  func read<T>(_ reader: (DatabaseReader) throws -> T) throws -> T

  @discardableResult
  func write<T>(shouldSyncChange: Bool, _ writer: (inout DatabaseWriter) throws -> T) throws -> T

  func publisher(with id: Identifier) -> AnyPublisher<PersonalDataRecord?, Error>
  func publisher(withParentId id: Identifier) -> AnyPublisher<PersonalDataRecord?, Error>
  func metadataPublisher(with id: Identifier) -> AnyPublisher<RecordMetadata?, Error>
}

extension DatabaseDriver {
  @discardableResult
  public func write<T>(_ writer: (inout DatabaseWriter) throws -> T) throws -> T {
    return try write(shouldSyncChange: true, writer)
  }
}
