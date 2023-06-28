import Foundation
import GRDB
import SwiftTreats
import DatabaseFoundation

public struct SQLiteDatabase {
    let pool: DatabasePool

    public init(url: URL) throws {
        pool = try DatabasePool.makeShared(databaseURL: url, name: "SharingDB")

        try configureTable()
    }
}
