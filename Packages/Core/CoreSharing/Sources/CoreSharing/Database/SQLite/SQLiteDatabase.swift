import DatabaseFoundation
import Foundation
import GRDB
import SwiftTreats

public struct SQLiteDatabase {
  let pool: DatabasePool

  public init(url: URL) throws {
    pool = try DatabasePool.makeShared(databaseURL: url, name: "SharingDB")

    try configureTable()
  }
}
