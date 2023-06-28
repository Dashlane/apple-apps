import Foundation
import GRDB
import UniformTypeIdentifiers
import DashTypes

struct SQLiteRawRecord: Identifiable, Codable, FetchableRecord, PersistableRecord {
    public static var databaseDateEncodingStrategy: DatabaseDateEncodingStrategy { .timeIntervalSince1970 }
    public static var databaseDateDecodingStrategy: DatabaseDateDecodingStrategy { .timeIntervalSince1970 }

    static let databaseTableName = "personalData"

    enum CodingKeys: String, CodingKey, ColumnExpression, CaseIterable {
        case encryptedContent
    }

    var id: Identifier {
        return metadata.id
    }

            let metadata: RecordMetadata

        let encryptedContent: Data

    init(info: RecordMetadata, encryptedContent: Data) {
        self.metadata = info
        self.encryptedContent = encryptedContent
    }

    init(from decoder: Decoder) throws {
        metadata = try RecordMetadata(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        encryptedContent = try container.decode(Data.self, forKey: .encryptedContent)
    }

    func encode(to encoder: Encoder) throws {
        try metadata.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(encryptedContent, forKey: .encryptedContent)
    }
}

extension RecordMetadata.CodingKeys: ColumnExpression { }
extension RecordMetadata: FetchableRecord, PersistableRecord {
    public static var databaseDateEncodingStrategy: DatabaseDateEncodingStrategy { .timeIntervalSince1970 }
    public static var databaseDateDecodingStrategy: DatabaseDateDecodingStrategy { .timeIntervalSince1970 }

    public static var databaseTableName: String {
        SQLiteRawRecord.databaseTableName
    }
}

extension Identifier: DatabaseValueConvertible {
    public var databaseValue: DatabaseValue { rawValue.databaseValue }

    public static func fromDatabaseValue(_ dbValue: DatabaseValue) -> Self? {
        guard let raw = String.fromDatabaseValue(dbValue) else {
            return nil
        }

        return .init(raw)
    }
}
