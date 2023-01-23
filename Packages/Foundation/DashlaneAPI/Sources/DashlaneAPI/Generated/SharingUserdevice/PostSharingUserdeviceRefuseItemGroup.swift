import Foundation
extension UserDeviceAPIClient.SharingUserdevice {
        public struct RefuseItemGroup {
        public static let endpoint: Endpoint = "/sharing-userdevice/RefuseItemGroup"

        public let api: UserDeviceAPIClient

                public func callAsFunction(revision: Int, groupId: String, auditLogDetails: AuditLogDetails? = nil, itemsForEmailing: [ItemForEmailing]? = nil, userGroupId: String? = nil, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(revision: revision, groupId: groupId, auditLogDetails: auditLogDetails, itemsForEmailing: itemsForEmailing, userGroupId: userGroupId)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var refuseItemGroup: RefuseItemGroup {
        RefuseItemGroup(api: api)
    }
}

extension UserDeviceAPIClient.SharingUserdevice.RefuseItemGroup {
        struct Body: Encodable {

                public let revision: Int

                public let groupId: String

        public let auditLogDetails: AuditLogDetails?

                public let itemsForEmailing: [ItemForEmailing]?

                public let userGroupId: String?
    }
}

extension UserDeviceAPIClient.SharingUserdevice.RefuseItemGroup {
    public typealias Response = ServerResponse
}
