import Foundation
import DashTypes
import DashlaneAPI

public struct UserGroupMember: Codable, Hashable, Identifiable {

        public let id: Identifier
        let itemGroupId: Identifier
                public let name: String
        public let status: SharingMemberStatus
        public let permission: SharingPermission
        public let encryptedGroupKey: String?
        public let proposeSignature: String?
        public let acceptSignature: String?

    public init(id: Identifier, itemGroupId: Identifier, name: String, status: SharingMemberStatus, permission: SharingPermission, encryptedGroupKey: String? = nil, proposeSignature: String? = nil, acceptSignature: String? = nil) {
        self.id = id
        self.itemGroupId = itemGroupId
        self.name = name
        self.status = status
        self.permission = permission
        self.encryptedGroupKey = encryptedGroupKey
        self.proposeSignature = proposeSignature
        self.acceptSignature = acceptSignature
    }
}

extension UserGroupMember {
    public var parentGroupId: Identifier {
        return itemGroupId
    }
}

extension UserGroupMember {
    init(groupMember: ItemGroupDownload.Groups, itemGroupId: Identifier) {
        id = .init(groupMember.groupId)
        self.itemGroupId = itemGroupId
        name = groupMember.name
        status = groupMember.status
        permission = .init(groupMember.permission)
        proposeSignature = groupMember.proposeSignature
        acceptSignature = groupMember.acceptSignature
        encryptedGroupKey = groupMember.groupKey
    }
}
