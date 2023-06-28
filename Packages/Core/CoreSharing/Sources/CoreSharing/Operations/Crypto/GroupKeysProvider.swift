import Foundation
import CyrilKit
import DashTypes

@SharingActor
class GroupKeyProvider {
        private struct Cache {
        let key: SymmetricKey
        let revision: SharingRevision
    }

    let userId: UserId
    let userKeyProvider: UserKeyProvider
    let database: SharingOperationsDatabase
    let cryptoProvider: SharingCryptoProvider
    private var groupKeysCache: [Identifier: Cache] = [:]

    init(userId: UserId,
         userKeyProvider: @escaping UserKeyProvider,
         database: SharingOperationsDatabase,
         cryptoProvider: SharingCryptoProvider) {
        self.userId = userId
        self.userKeyProvider = userKeyProvider
        self.database = database
        self.cryptoProvider = cryptoProvider
    }

                    func groupKey(for group: UserGroup) throws -> SymmetricKey? {
        return try cache(forId: group.id, revision: group.info.revision) { () throws -> SymmetricKey? in
            guard let user = group.user(with: userId) else {
                return nil
            }

            return try groupKey(for: user)
        }
    }

                    func groupKey(for group: ItemGroup) throws -> SymmetricKey? {
        return try cache(forId: group.id, revision: group.info.revision) { () throws -> SymmetricKey? in
                        if let user = group.user(with: userId) {
                return try groupKey(for: user)
            }
                        else {
                return try group.userGroupMembers.lazy.compactMap {
                    try groupKey(for: $0)
                }.first
            }
        }
    }

        private func groupKey(for user: User) throws -> SymmetricKey? {
        guard user.status.isAcceptedOrPending else {
            return nil
        }

        return try user.groupKey(using: cryptoProvider.decrypter(using: try self.userKeyProvider().privateKey))
    }

                    private func groupKey(for userGroupMember: UserGroupMember) throws -> SymmetricKey? {
        guard userGroupMember.status.isAcceptedOrPending else {
            return nil
        }

        guard let keys = try keys(for: userGroupMember) else {
            return nil
        }

        return keys.itemGroupKey
    }
        func privateKey(for userGroup: UserGroup) throws -> PrivateKey? {
        guard let groupKey = try groupKey(for: userGroup) else {
            return nil
        }

        let privatePemString = try userGroup.info.privateKey(using: cryptoProvider.cryptoEngine(using: groupKey))
        let privateKey = try cryptoProvider.privateKey(fromPemString: privatePemString)

        return privateKey
    }

        func keys(for userGroupMember: UserGroupMember) throws -> (itemGroupKey: SymmetricKey, privateKey: PrivateKey)? {
        guard userGroupMember.status.isAcceptedOrPending else {
            return nil
        }

        guard let pair = try database.fetchUserGroupUserPair(withGroupId: userGroupMember.id, userId: userId),
              pair.user.status == .accepted,
              let groupKey = try cache(forId: pair.group.id, revision: pair.group.revision, {
                  try self.groupKey(for: pair.user)
              }) else {
            return nil
        }

        let privatePemString = try pair.group.privateKey(using: cryptoProvider.cryptoEngine(using: groupKey))
        let privateKey = try cryptoProvider.privateKey(fromPemString: privatePemString)
        let itemGroupKey = try userGroupMember.groupKey(using: cryptoProvider.decrypter(using: privateKey))

        let keys = (itemGroupKey: itemGroupKey, privateKey: privateKey)

        return keys
    }

                    private func cache(forId id: Identifier, revision: SharingRevision, _ computation: () throws -> SymmetricKey?) throws -> SymmetricKey? {
        if let cache = groupKeysCache[id], cache.revision == revision {
            return cache.key
        }
        guard let key = try computation() else {
            return nil
        }

        groupKeysCache[id] = Cache(key: key, revision: revision)
        return key
    }
}

extension SharingGroupMember {
                func groupKey(using decrypter: Decrypter) throws -> SymmetricKey {
        guard let keyBase64 = encryptedGroupKey,
              !keyBase64.isEmpty,
              let encryptedKey = Data(base64Encoded: keyBase64) else {
            throw SharingGroupError.missingKey(.groupKey)
        }

        return try decrypter.decrypt(encryptedKey)
    }
}

extension UserGroupInfo {
                func privateKey(using engine: CryptoEngine) throws -> String {
        guard let data = Data(base64Encoded: encryptedPrivateKey) else {
            throw SharingGroupError.missingKey(.privateKey)
        }

        let decryptedData = try data.decrypt(using: engine)
        guard let pemString = String(data: decryptedData, encoding: .utf8) else {
            throw SharingGroupError.unknown
        }

        return pemString
    }
}
