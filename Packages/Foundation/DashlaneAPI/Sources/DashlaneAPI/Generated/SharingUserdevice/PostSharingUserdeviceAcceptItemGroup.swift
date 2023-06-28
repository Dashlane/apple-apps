import Foundation
extension UserDeviceAPIClient.SharingUserdevice {
        public struct AcceptItemGroup: APIRequest {
        public static let endpoint: Endpoint = "/sharing-userdevice/AcceptItemGroup"

        public let api: UserDeviceAPIClient

                public func callAsFunction(revision: Int, groupId: String, acceptSignature: String, auditLogDetails: AuditLogDetails? = nil, autoAccept: Bool? = nil, itemsForEmailing: [ItemForEmailing]? = nil, userGroupId: String? = nil, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(revision: revision, groupId: groupId, acceptSignature: acceptSignature, auditLogDetails: auditLogDetails, autoAccept: autoAccept, itemsForEmailing: itemsForEmailing, userGroupId: userGroupId)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }

        public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response {
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var acceptItemGroup: AcceptItemGroup {
        AcceptItemGroup(api: api)
    }
}

extension UserDeviceAPIClient.SharingUserdevice.AcceptItemGroup {
        public struct Body: Encodable {

        private enum CodingKeys: String, CodingKey {
            case revision = "revision"
            case groupId = "groupId"
            case acceptSignature = "acceptSignature"
            case auditLogDetails = "auditLogDetails"
            case autoAccept = "autoAccept"
            case itemsForEmailing = "itemsForEmailing"
            case userGroupId = "userGroupId"
        }

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
