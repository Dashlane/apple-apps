import Foundation
extension UserDeviceAPIClient.SharingUserdevice {
        public struct InviteItemGroupMembers {
        public static let endpoint: Endpoint = "/sharing-userdevice/InviteItemGroupMembers"

        public let api: UserDeviceAPIClient

                public func callAsFunction(revision: Int, groupId: String, auditLogDetails: AuditLogDetails? = nil, groups: [UserGroupInvite]? = nil, itemsForEmailing: [ItemForEmailing]? = nil, users: [UserInvite]? = nil, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(revision: revision, groupId: groupId, auditLogDetails: auditLogDetails, groups: groups, itemsForEmailing: itemsForEmailing, users: users)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var inviteItemGroupMembers: InviteItemGroupMembers {
        InviteItemGroupMembers(api: api)
    }
}

extension UserDeviceAPIClient.SharingUserdevice.InviteItemGroupMembers {
        struct Body: Encodable {

                public let revision: Int

                public let groupId: String

        public let auditLogDetails: AuditLogDetails?

                public let groups: [UserGroupInvite]?

                public let itemsForEmailing: [ItemForEmailing]?

                public let users: [UserInvite]?
    }
}

extension UserDeviceAPIClient.SharingUserdevice.InviteItemGroupMembers {
    public typealias Response = ServerResponse
}
