import GRDB

extension SharingCollection: FetchableRecord {
  static let request =
    CollectionInfo
    .including(all: CollectionInfo.userGroupMembers)
    .including(all: CollectionInfo.users)
    .asRequest(of: CollectionInfo.self)

  func insert(_ db: Database) throws {
    try info.insert(db)
    try users.forEach { try $0.insert(db) }
    try userGroupMembers.forEach { try $0.insert(db) }
  }

  func save(_ db: Database) throws {
    if let existing = try SharingCollection.fetchOne(db, SharingCollection.request.filter(id: id)) {
      try info.update(db)
      try users.update(db, from: existing.users)
      try userGroupMembers.update(db, from: existing.userGroupMembers)
    } else {
      try insert(db)
    }
  }
}

extension CollectionInfo: TableRecord, FetchableRecord, PersistableRecord {
  public static var databaseTableName: String = "collection"

  static let userGroupMembers = hasMany(UserGroupMember<SharingCollection>.self)
  static let users = hasMany(User<SharingCollection>.self)

  static let userGroups = hasMany(
    UserGroupInfo.self, through: CollectionInfo.userGroupMembers,
    using: UserGroupMember<SharingCollection>.userGroup)
  static let usersThroughGroupMembers = hasMany(
    User<UserGroup>.self, through: CollectionInfo.userGroups, using: UserGroupInfo.users)

  static func havingAcceptedUser(with userId: UserId) -> QueryInterfaceRequest<Self> {
    return self.having(
      Self.users.filter(id: userId).filter(status: .accepted).isNotEmpty()
        || Self.usersThroughGroupMembers.filter(id: userId).filter(status: .accepted).isNotEmpty()
    )
  }
}
