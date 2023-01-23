import Foundation
import Combine
import DashTypes

public protocol DatabaseDriver {
        var eventPublisher: PassthroughSubject<DatabaseEvent, Never> { get }
        var syncTriggerPublisher: PassthroughSubject<Void, Never> { get }

    func read<T>(_ reader: (DatabaseReader) throws -> T) throws -> T
    
    @discardableResult
    func write<T>(shouldSyncChange: Bool, _ writer: (inout DatabaseWriter) throws -> T) throws -> T
    
    func publisher(with id: Identifier) -> AnyPublisher<PersonalDataRecord?, Error>
    func metadataPublisher(with id: Identifier) -> AnyPublisher<RecordMetadata?, Error>
}

public extension DatabaseDriver {
    @discardableResult
    func write<T>(_ writer: (inout DatabaseWriter) throws -> T) throws -> T {
        return try write(shouldSyncChange: true, writer)
    }
}
