import Foundation
import GRDB
import DashTypes

extension ItemGroup: FetchableRecord {
    static let request = ItemGroupInfo
        .including(all: ItemGroupInfo.userGroupMembers)
        .including(all: ItemGroupInfo.users)
        .including(all: ItemGroupInfo.itemKeyPairs)
        .asRequest(of: ItemGroupInfo.self)

    func insert(_ db: Database) throws {
        try info.insert(db)
        try users.forEach { try $0.insert(db) }
        try userGroupMembers.forEach { try $0.insert(db) }
        try itemKeyPairs.forEach { try $0.insert(db) }
    }

    func save(_ db: Database) throws {
        if let existing = try ItemGroup.fetchOne(db, ItemGroup.request.filter(id: id)) {
            try info.update(db)
            try users.update(db, from: existing.users)
            try userGroupMembers.update(db, from: existing.userGroupMembers)
            try itemKeyPairs.update(db, from: existing.itemKeyPairs)
        } else {
            try insert(db)
        }
    }
}

extension ItemGroupInfo: TableRecord, FetchableRecord, PersistableRecord {
    public static var databaseTableName: String = "itemGroup"

    static let userGroupMembers = hasMany(UserGroupMember.self)
    static let users = hasMany(User.self)
    static let itemKeyPairs = hasMany(ItemKeyPair.self)
    static let itemIds = Self.itemKeyPairs.select(Column.id)

    static let userGroups = hasMany(UserGroupInfo.self, through: ItemGroupInfo.userGroupMembers, using: UserGroupMember.userGroup)
    static let usersThoughGroupMembers = hasMany(User.self, through: ItemGroupInfo.userGroups, using: UserGroupInfo.users)

    static func havingAcceptedUser(with userId: UserId) -> QueryInterfaceRequest<Self> {
        return self.having(
            Self.users.filter(id: userId).filter(status: .accepted).isNotEmpty()
            ||
            Self.usersThoughGroupMembers.filter(id: userId).filter(status: .accepted).isNotEmpty()
        )
    }

}

extension ItemKeyPair: TableRecord, FetchableRecord, PersistableRecord {
    static let parentGroup = belongsTo(ItemGroupInfo.self)
}
