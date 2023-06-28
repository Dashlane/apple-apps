import Foundation
import DashTypes
import DashlaneAPI

public struct User: Codable, Hashable, Identifiable {
        public let id: String
        public let parentGroupId: Identifier
        let userGroupId: Identifier?
        let itemGroupId: Identifier?
        public let referrer: String
        public var status: SharingMemberStatus
        public var encryptedGroupKey: String?
        public var permission: SharingPermission
        public var proposeSignature: String?
        public var acceptSignature: String?
                        public var rsaStatus: RSAStatus

    public init(
        id: String,
        parentGroupId: Identifier,
        userGroupId: Identifier? = nil,
        itemGroupId: Identifier? = nil,
        referrer: String,
        status: SharingMemberStatus,
        encryptedGroupKey: String? = nil,
        permission: SharingPermission,
        proposeSignature: String? = nil,
        acceptSignature: String? = nil,
        rsaStatus: RSAStatus
    ) {
        self.id = id
        self.parentGroupId = parentGroupId
        self.userGroupId = userGroupId
        self.itemGroupId = itemGroupId
        self.referrer = referrer
        self.status = status
        self.encryptedGroupKey = encryptedGroupKey
        self.permission = permission
        self.proposeSignature = proposeSignature
        self.acceptSignature = acceptSignature
        self.rsaStatus = rsaStatus
    }
}

extension User {
    init(user: UserDownload, groupIdentifier: GroupIdentifier) {
        id = user.userId
        switch groupIdentifier {
            case .itemGroup(let id):
                self.parentGroupId = id
                self.itemGroupId = id
                self.userGroupId = nil

            case .userGroup(let id):
                self.parentGroupId = id
                self.itemGroupId = nil
                self.userGroupId = id
        }
        encryptedGroupKey = user.groupKey
        permission = .init(user.permission)
        proposeSignature = user.proposeSignature
        acceptSignature = user.acceptSignature
        referrer = user.referrer
        rsaStatus = user.rsaStatus ?? .noKey
        status = user.status ?? .pending
    }
}

extension SharingPermission {
    init(_ permission: Permission) {
        switch permission {
        case .admin:
            self = .admin
        case .limited:
            self = .limited
        }
    }
}

extension Permission {
    init(_ permission: SharingPermission) {
        switch permission {
        case .admin:
            self = .admin
        case .limited:
            self = .limited
        }
    }
}
