import CoreTypes
import Foundation
import GRDB

struct SQLiteRawSnapshot: Identifiable, Codable, FetchableRecord, PersistableRecord {
  static let databaseTableName = "personalDataSnapshot"

  let id: Identifier
  let encryptedContent: Data
}
