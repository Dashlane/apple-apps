import Foundation
import DashTypes
import CyrilKit
import DashlaneAPI

public struct ItemGroup: Codable, Hashable, Identifiable {
    public var id: Identifier {
        info.id
    }
    public var info: ItemGroupInfo
                public var itemKeyPairs: [ItemKeyPair]
        public var users: [User]
        public var userGroupMembers: [UserGroupMember]

    public init(info: ItemGroupInfo, itemKeyPairs: [ItemKeyPair], users: [User], userGroupMembers: [UserGroupMember]) {
        self.info = info
        self.itemKeyPairs = itemKeyPairs
        self.users = users
        self.userGroupMembers = userGroupMembers
    }

    public init(_ itemGroupDownload: ItemGroupDownload) {
        let info = ItemGroupInfo(itemGroupDownload)
        self.info = info
        itemKeyPairs = itemGroupDownload.items?.map { ItemKeyPair($0, itemGroupId: info.id) } ?? []
        users = itemGroupDownload.users?.map { User(user: $0, groupIdentifier: .itemGroup(info.id)) } ?? []
        userGroupMembers = itemGroupDownload.groups?.map { UserGroupMember(groupMember: $0, itemGroupId: .init(itemGroupDownload.groupId)) } ?? []
    }
}

extension ItemGroup {
    func userGroupMember(withId id: Identifier) -> UserGroupMember? {
        return userGroupMembers.first {  $0.id == id }
    }
}

extension Collection where Element == ItemGroup {
    func filter(forItemIds ids: Set<Identifier>) -> [ItemGroup] {
        filter {
            $0.itemKeyPairs.contains { ids.contains($0.id) }
        }
    }

    func union(_ groups: [ItemGroup]) -> [ItemGroup] {
        return Array(Dictionary(values: self).merging(Dictionary(values: groups)) { group, _ in
            group
        }.values)
    }
}

public struct ItemGroupInfo: Codable, Hashable, Identifiable {
        public let id: Identifier
            public var revision: SharingRevision
        public var teamId: Int?

    public init(id: Identifier = Identifier(), revision: Int = 1, teamId: Int? = nil) {
        self.id = id
        self.revision = revision
        self.teamId = teamId
    }
}

extension ItemGroupInfo {
    init(_ group: ItemGroupDownload) {
        id = .init(group.groupId)
        revision = group.revision
        teamId = group.teamId
    }
}

public struct ItemKeyPair: Codable, Hashable, Identifiable {
        public let id: Identifier
        public let itemGroupId: Identifier
        public var encryptedKey: String
}

extension ItemKeyPair {
    init(_ itemKey: ItemGroupDownload.Items, itemGroupId: Identifier) {
        id = .init(itemKey.itemId)
        encryptedKey = itemKey.itemKey
        self.itemGroupId = itemGroupId
    }
}

extension ItemKeyPair {
                func key(using engine: CryptoEngine) throws -> SymmetricKey {
        let encryptedKeyBase64 = encryptedKey
        guard !encryptedKeyBase64.isEmpty,
              let encryptedKey = Data(base64Encoded: encryptedKeyBase64) else {
            throw SharingGroupError.missingKey(.itemKey)
        }

        return try encryptedKey.decrypt(using: engine)
    }
}
