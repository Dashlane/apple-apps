import Foundation

enum SQLiteError: Error {
  case open(errorCode: Int32, message: String)
  case query(errorCode: Int32, message: String)
}

typealias SQLRow = [String: String]

struct QueryResult {
  let rows: [SQLRow]
  let columnNames: [String]

  public func data(forRow rowIndex: Int, columnName: String) -> String? {
    guard rowIndex < rows.count else { return nil }
    return rows[rowIndex][columnName]
  }
}
