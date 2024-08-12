import Foundation
import GRDB

extension DatabasePool {
  public static func makeShared(databaseURL: URL, name: String) throws -> DatabasePool {
    let coordinator = NSFileCoordinator(filePresenter: nil)
    var coordinatorError: NSError?
    var dbPool: DatabasePool?
    var dbError: Error?
    coordinator.coordinate(
      writingItemAt: databaseURL, options: .forMerging, error: &coordinatorError,
      byAccessor: { url in
        do {
          dbPool = try make(databaseURL: url, name: name)
          #if !DEBUG
            try? FileManager.default.clearFileProtection(in: url.deletingLastPathComponent())
          #endif
        } catch {
          dbError = error
        }
      })
    if let error = dbError ?? coordinatorError {
      throw error
    }
    return dbPool!
  }

  private static func make(databaseURL: URL, name: String) throws -> DatabasePool {
    var configuration = Configuration()
    configuration.label = name
    configuration.busyMode = .timeout(3)
    configuration.prepareDatabase { db in
      if db.configuration.readonly == false {
        var flag: CInt = 1
        let code = withUnsafeMutablePointer(to: &flag) { flagP in
          sqlite3_file_control(db.sqliteConnection, nil, SQLITE_FCNTL_PERSIST_WAL, flagP)
        }
        guard code == SQLITE_OK else {
          throw GRDB.DatabaseError(resultCode: ResultCode(rawValue: code))
        }
      }
    }
    let dbPool = try DatabasePool(path: databaseURL.path, configuration: configuration)

    return dbPool
  }
}
