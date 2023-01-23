import Foundation
extension UserDeviceAPIClient.SharingUserdevice {
        public struct CreateItemGroup {
        public static let endpoint: Endpoint = "/sharing-userdevice/CreateItemGroup"

        public let api: UserDeviceAPIClient

                public func callAsFunction(groupId: String, users: [UserUpload], items: [ItemUpload], auditLogDetails: AuditLogDetails? = nil, groups: [UserGroupInvite]? = nil, itemsForEmailing: [ItemForEmailing]? = nil, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(groupId: groupId, users: users, items: items, auditLogDetails: auditLogDetails, groups: groups, itemsForEmailing: itemsForEmailing)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var createItemGroup: CreateItemGroup {
        CreateItemGroup(api: api)
    }
}

extension UserDeviceAPIClient.SharingUserdevice.CreateItemGroup {
        struct Body: Encodable {

                public let groupId: String

                public let users: [UserUpload]

                public let items: [ItemUpload]

        public let auditLogDetails: AuditLogDetails?

                public let groups: [UserGroupInvite]?

                public let itemsForEmailing: [ItemForEmailing]?
    }
}

extension UserDeviceAPIClient.SharingUserdevice.CreateItemGroup {
    public typealias Response = ServerResponse
}
