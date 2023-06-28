import Foundation
import GRDB
extension SQLiteDatabase {
    func configureTable() throws {
        var migrator = DatabaseMigrator()
#if DEBUG
                migrator.eraseDatabaseOnSchemaChange = true
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

                        try db.create(table: UserGroupMember.databaseTableName, ifNotExists: true) { t in
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

            try db.create(table: User.databaseTableName, ifNotExists: true) { t in
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

        try migrator.migrate(pool)
    }
}
