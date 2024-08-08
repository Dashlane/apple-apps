import Foundation
import GRDB

protocol SQLiteDataCoder {
  func encode(_ record: PersonalDataRecord) throws -> SQLiteRawRecord
  func decode(_ record: SQLiteRawRecord) throws -> PersonalDataRecord
  func encode(_ snapshot: PersonalDataSnapshot) throws -> SQLiteRawSnapshot
  func decode(_ snapshot: SQLiteRawSnapshot) throws -> PersonalDataSnapshot
}

struct SQLiteDatabaseWrapper {
  let db: Database
  let coder: SQLiteDataCoder
  var changes: Set<DatabaseChange> = []
}
