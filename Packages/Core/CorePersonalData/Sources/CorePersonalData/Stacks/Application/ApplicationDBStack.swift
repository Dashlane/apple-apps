import Foundation
import DashTypes

public struct ApplicationDBStack: ApplicationDatabase {
    public let driver: DatabaseDriver
    public let logger: Logger

    let decoder: PersonalDataDecoder
    let encoder = PersonalDataEncoder()
    let historyUpdater: HistoryUpdater
    let sharingUploadTrigger = SharingUploadTrigger()
    
    public init(driver: DatabaseDriver,
                historyUserInfo: HistoryUserInfo,
                codeDecoder: CodeDecoder?,
                personalDataURLDecoder: PersonalDataURLDecoder?,
                logger: Logger) {
        self.driver = driver
        self.logger = logger
        historyUpdater = HistoryUpdater(info: historyUserInfo)
        
        self.decoder = PersonalDataDecoder(codeDecoder: codeDecoder,
                                           personalDataURLDecoder: personalDataURLDecoder)
    }
    
    @inline(__always)
    private func decodeIgnoringErrors<Output: PersonalDataCodable>(_ output: Output.Type, from records: [PersonalDataRecord]) -> [Output] {
        return records.compactMap {
            do {
                return try decoder.decode(Output.self, from: $0, using: makeLinkedFetcher())
            } catch {
                logger.fatal("Cannot decode type \(type(of: output))", error: error)
                return nil
            }
        }
    }
    
    @inline(__always)
    func decode<Output: PersonalDataCodable>(_ output: Output.Type, from records: [PersonalDataRecord], ignoreDecodingErrors: Bool) throws -> [Output] {
        if ignoreDecodingErrors {
            return decodeIgnoringErrors(output, from: records)
        } else {
            return try records.map {
                try decoder.decode(Output.self, from: $0, using: makeLinkedFetcher())
            }
        }
    }
    
    @inline(__always)
    func decode<Output: PersonalDataCodable>(_ output: Output.Type, from record: PersonalDataRecord) throws -> Output {
        try decoder.decode(Output.self, from: record, using: makeLinkedFetcher())
    }
    
    @inline(__always)
    func makeLinkedFetcher() -> LinkedFetcher {
        LinkedFetcherImpl(driver: driver)
    }
}

class LinkedFetcherImpl: LinkedFetcher {
    var caches: [Identifier: PersonalDataRecord] = [:]
    let decoder = PersonalDataDecoder()
    let driver: DatabaseDriver
    
    public init(driver: DatabaseDriver) {
        self.driver = driver
    }
    
    func fetch<T: PersonalDataCodable>(with id: Identifier, type: T.Type) throws -> T? {
        guard let record = try fetchRecord(with: id) else {
            return nil
        }
        return try decoder.decode(T.self, from: record)
    }
    
    private func fetchRecord(with id: Identifier) throws -> PersonalDataRecord? {
        if let cached = caches[id] {
            return cached
        } else if let record = try driver.read({ try $0.fetchOne(with: id) }) {
            caches[id] = record
            return record
        } else {
            return nil
        }
    }
}

public extension ApplicationDBStack {
    static func mock(items: [PersonalDataCodable] = []) -> ApplicationDatabase {
        let database = ApplicationDBStack(driver: InMemoryDatabaseDriver(),
                                          historyUserInfo: HistoryUserInfo(platform: "server_iphone", deviceName: "iPhone", user: "Dominique"),
                                          codeDecoder: nil,
                                          personalDataURLDecoder: nil,
                                          logger: LoggerMock())
        items.forEach { item in
            try! database.save(item)
        }

        return database
    }
}
