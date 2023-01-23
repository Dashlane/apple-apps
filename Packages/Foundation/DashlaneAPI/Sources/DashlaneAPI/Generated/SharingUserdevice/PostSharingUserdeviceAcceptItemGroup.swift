import Foundation
extension UserDeviceAPIClient.SharingUserdevice {
        public struct AcceptItemGroup {
        public static let endpoint: Endpoint = "/sharing-userdevice/AcceptItemGroup"

        public let api: UserDeviceAPIClient

                public func callAsFunction(revision: Int, groupId: String, acceptSignature: String, auditLogDetails: AuditLogDetails? = nil, autoAccept: Bool? = nil, itemsForEmailing: [ItemForEmailing]? = nil, userGroupId: String? = nil, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(revision: revision, groupId: groupId, acceptSignature: acceptSignature, auditLogDetails: auditLogDetails, autoAccept: autoAccept, itemsForEmailing: itemsForEmailing, userGroupId: userGroupId)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var acceptItemGroup: AcceptItemGroup {
        AcceptItemGroup(api: api)
    }
}

extension UserDeviceAPIClient.SharingUserdevice.AcceptItemGroup {
        struct Body: Encodable {

                public let revision: Int

                public let groupId: String

                public let acceptSignature: String

        public let auditLogDetails: AuditLogDetails?

                public let autoAccept: Bool?

                public let itemsForEmailing: [ItemForEmailing]?

                public let userGroupId: String?
    }
}

extension UserDeviceAPIClient.SharingUserdevice.AcceptItemGroup {
    public typealias Response = ServerResponse
}
