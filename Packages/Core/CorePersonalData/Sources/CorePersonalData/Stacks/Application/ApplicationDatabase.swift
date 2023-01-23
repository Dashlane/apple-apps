import Foundation
import Combine
import DashTypes

public protocol ApplicationDatabase {
        func fetchAll<Output: PersonalDataCodable>(_ type: Output.Type, ignoreDecodingErrors: Bool) throws -> [Output]
    
        func fetch<Output: PersonalDataCodable>(with id: Identifier, type: Output.Type) throws -> Output?
    
        func fetchAll<Output: PersonalDataCodable>(with ids: [Identifier], type: Output.Type, ignoreDecodingErrors: Bool) throws -> [Output]
    
        func count<Item: PersonalDataCodable>(for item: Item.Type) throws -> Int

        func itemsPublisher<Output: PersonalDataCodable>(for output: Output.Type) -> PersonalDataPublisher<Output>
    
        func fetchedPersonalData<Output: PersonalDataCodable>(for output: Output.Type) -> FetchedPersonalData<Output>

        func itemPublisher<Output: PersonalDataCodable>(for id: Identifier, type: Output.Type) -> AnyPublisher<Output, Error>

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
}

public enum LastUseUpdateOrigin: Hashable {
    case `default`
    case search
}

public extension ApplicationDatabase {
        func fetchAll<Output: PersonalDataCodable>(_ type: Output.Type) throws -> [Output] {
        try fetchAll(type, ignoreDecodingErrors: true)
    }
    
        func fetchAll<Output: PersonalDataCodable>(with ids: [Identifier], type: Output.Type) throws -> [Output] {
        try fetchAll(with: ids, type: type, ignoreDecodingErrors: true)
    }
}
