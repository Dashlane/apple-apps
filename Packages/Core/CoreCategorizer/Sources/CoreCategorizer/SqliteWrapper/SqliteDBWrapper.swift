import Foundation
import SQLite3

public class SqliteDBWrapper {
    var dbPointer: OpaquePointer
    
            init(dbPath: String) throws {
        var dbPointer: OpaquePointer?
        let openStatus = sqlite3_open_v2(dbPath, &dbPointer, SQLITE_OPEN_READONLY|SQLITE_OPEN_FULLMUTEX, nil)
        guard openStatus == SQLITE_OK else {
            throw SQLiteError.open(errorCode: openStatus, message: "")
        }
        self.dbPointer = dbPointer!
    }
    
        func query(statement: String) throws -> QueryResult {
        var queryStatement: OpaquePointer? = nil
        
        let status = sqlite3_prepare_v2(dbPointer, statement, -1, &queryStatement, nil)
        defer {
                        sqlite3_finalize(queryStatement)
        }
        guard status == SQLITE_OK else { throw SQLiteError.query(errorCode: status, message: errorMessage()) }
        
        let columnNames: [String] = getColumnNames(preparedStatement: queryStatement)
        let columnCount = columnNames.count
        var rows = [[String: String]]()
        
        while (sqlite3_step(queryStatement) == SQLITE_ROW) {
            
            var rowDictionary = [String: String]()
            for columnIndex in 0..<columnCount {
                if let value = sqlite3_column_text(queryStatement, Int32(columnIndex)) {
                    let name  = columnNames[columnIndex]
                    rowDictionary[name] = String(cString: value)
                }
            }
            rows.append(rowDictionary)
        }
        return QueryResult(rows: rows, columnNames: columnNames)
    }
    
    deinit {
        sqlite3_close(dbPointer)
    }
}

extension SqliteDBWrapper {

        private func errorMessage() -> String {
        if let cString = sqlite3_errmsg(dbPointer) {
            return String(cString: cString)
        }
        return ""
    }
    
        private func getColumnNames(preparedStatement: OpaquePointer?) -> [String] {
        let columnCount = sqlite3_column_count(preparedStatement)
        return (0..<columnCount).compactMap { columnIndex in
            return String(cString: sqlite3_column_name(preparedStatement, columnIndex))
        }
    }
    
}
