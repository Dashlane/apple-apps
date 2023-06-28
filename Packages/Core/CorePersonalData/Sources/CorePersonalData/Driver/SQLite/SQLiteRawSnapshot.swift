import Foundation
import GRDB
import DashTypes

struct SQLiteRawSnapshot: Identifiable, Codable, FetchableRecord, PersistableRecord {
    static let databaseTableName = "personalDataSnapshot"

    let id: Identifier
        let encryptedContent: Data
}
