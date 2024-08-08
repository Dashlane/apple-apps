import Foundation
import GRDB

extension UserGroup: FetchableRecord {
  static let request =
    UserGroupInfo
    .including(all: UserGroupInfo.users)
    .asRequest(of: UserGroup.self)

  func insert(_ db: Database) throws {
    try info.insert(db)
    try users.forEach { try $0.insert(db) }
  }

  func save(_ db: Database) throws {
    if let existing = try UserGroup.fetchOne(db, Self.request.filter(id: id)) {
      try info.update(db)
      try users.update(db, from: existing.users)
    } else {
      try insert(db)
    }
  }
}

extension UserGroupInfo: TableRecord, FetchableRecord, PersistableRecord {
  public static var databaseTableName: String = "userGroup"

  static let users = hasMany(User<UserGroup>.self)
}
