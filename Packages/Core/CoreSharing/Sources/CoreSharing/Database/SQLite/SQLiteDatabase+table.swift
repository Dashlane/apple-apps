import Foundation
import GRDB

extension SQLiteDatabase {
  func configureTable() throws {
    var migrator = DatabaseMigrator()
    #if DEBUG
    #endif

    migrator.registerMigration("v1") { db in
      try db.create(table: ItemGroupInfo.databaseTableName, ifNotExists: true) { t in
        t.column("id", .text)
          .primaryKey(onConflict: .replace)
        t.column("teamId", .integer)
        t.column("revision", .integer)
          .notNull(onConflict: .ignore)
      }

      try db.create(table: UserGroupInfo.databaseTableName, ifNotExists: true) { t in
        t.column("id", .text)
          .primaryKey(onConflict: .replace)

        t.column("name", .text)
        t.column("publicKey", .text)
        t.column("encryptedPrivateKey", .text)
        t.column("revision", .integer)
          .notNull(onConflict: .ignore)
      }

      try db.create(table: ItemKeyPair.databaseTableName, ifNotExists: true) { t in
        t.column("id", .text)
          .notNull()
          .indexed()

        t.column("itemGroupId", .text)
          .notNull()
          .indexed()
          .references("itemGroup", onDelete: .cascade)

        t.primaryKey(["id", "itemGroupId"])

        t.column("encryptedKey", .blob)
      }

      try db.create(table: UserGroupMember<ItemGroup>.databaseTableName, ifNotExists: true) { t in
        t.column("id", .text)
          .notNull()
          .indexed()

        t.column("itemGroupId", .text)
          .notNull()
          .indexed()
          .references("itemGroup", onDelete: .cascade)

        t.primaryKey(["id", "itemGroupId"])

        t.column("name", .text)
        t.column("status", .text)
        t.column("permission", .text)
        t.column("encryptedGroupKey", .text)
        t.column("proposeSignature", .text)
        t.column("acceptSignature", .text)
      }

      try db.create(table: User<ItemGroup>.databaseTableName, ifNotExists: true) { t in
        t.column("id", .text)
          .notNull()
          .indexed()

        t.column("parentGroupId", .text)
          .notNull()
          .indexed()

        t.primaryKey(["id", "parentGroupId"])

        t.column("itemGroupId", .text)
          .indexed()
          .references("itemGroup", onDelete: .cascade)

        t.column("userGroupId", .text)
          .indexed()
          .references("userGroup", onDelete: .cascade)

        t.column("referrer", .text)
        t.column("status", .text)
        t.column("permission", .text)
        t.column("encryptedGroupKey", .text)
        t.column("proposeSignature", .text)
        t.column("acceptSignature", .text)
        t.column("rsaStatus", .text)
      }

      try db.create(table: ItemContentCache.databaseTableName, ifNotExists: true) { t in
        t.column("id", .text)
          .primaryKey(onConflict: .replace)

        t.column("timestamp", .integer)

        t.column("encryptedContent", .blob)
      }
    }

    migrator.registerMigration("v2.collection") { db in
      try db.create(table: CollectionInfo.databaseTableName, ifNotExists: true) { t in
        t.column("id", .text)
          .primaryKey(onConflict: .replace)

        t.column("name", .text)
        t.column("publicKey", .text)
        t.column("encryptedPrivateKey", .text)
        t.column("revision", .integer)
          .notNull(onConflict: .ignore)
      }

      try db.create(table: CollectionMember.databaseTableName, ifNotExists: true) { t in
        t.column("id", .text)
          .notNull()
          .indexed()

        t.column("itemGroupId", .text)
          .notNull()
          .indexed()
          .references("itemGroup", onDelete: .cascade)

        t.primaryKey(["id", "itemGroupId"])

        t.column("name", .text)
        t.column("status", .text)
        t.column("permission", .text)
        t.column("encryptedGroupKey", .text)
        t.column("proposeSignature", .text)
        t.column("acceptSignature", .text)
      }

      try migrateUserGroupMemberTableForCollections(db)

      try db.alter(table: User<ItemGroup>.databaseTableName) { t in
        t.add(column: "collectionId", .text)
          .indexed()
          .references("collection", onDelete: .cascade)
      }
    }

    try migrator.migrate(pool)
  }
}

extension SQLiteDatabase {
  fileprivate func migrateUserGroupMemberTableForCollections(_ db: Database) throws {
    let newUserGroupMemberTableName = "new" + UserGroupMember<ItemGroup>.databaseTableName
    try db.create(table: newUserGroupMemberTableName, ifNotExists: true) { t in
      t.column("id", .text)
        .notNull()
        .indexed()

      t.column("parentGroupId", .text)
        .notNull()
        .indexed()

      t.column("itemGroupId", .text)
        .indexed()
        .references("itemGroup", onDelete: .cascade)

      t.column("collectionId", .text)
        .indexed()
        .references("collection", onDelete: .cascade)

      t.primaryKey(["id", "parentGroupId"])

      t.column("name", .text)
      t.column("status", .text)
      t.column("permission", .text)
      t.column("encryptedGroupKey", .text)
      t.column("proposeSignature", .text)
      t.column("acceptSignature", .text)
    }

    let userGroupMemberRows = try Row.fetchCursor(
      db, sql: "SELECT * FROM \(UserGroupMember<ItemGroup>.databaseTableName)")
    while let userGroupMemberRow = try userGroupMemberRows.next() {
      try db.execute(
        sql:
          "INSERT INTO \(newUserGroupMemberTableName) (id, parentGroupId, itemGroupId, collectionId, name, status, permission, encryptedGroupKey, proposeSignature, acceptSignature) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
        arguments: [
          userGroupMemberRow["id"],
          userGroupMemberRow["itemGroupId"],
          userGroupMemberRow["itemGroupId"],
          nil,
          userGroupMemberRow["name"],
          userGroupMemberRow["status"],
          userGroupMemberRow["permission"],
          userGroupMemberRow["encryptedGroupKey"],
          userGroupMemberRow["proposeSignature"],
          userGroupMemberRow["acceptSignature"],
        ]
      )
    }

    try db.drop(table: UserGroupMember<ItemGroup>.databaseTableName)
    try db.rename(
      table: newUserGroupMemberTableName, to: UserGroupMember<ItemGroup>.databaseTableName)
  }
}
