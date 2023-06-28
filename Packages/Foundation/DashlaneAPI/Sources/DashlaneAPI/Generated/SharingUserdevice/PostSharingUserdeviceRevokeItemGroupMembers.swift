import Foundation
extension UserDeviceAPIClient.SharingUserdevice {
        public struct RevokeItemGroupMembers: APIRequest {
        public static let endpoint: Endpoint = "/sharing-userdevice/RevokeItemGroupMembers"

        public let api: UserDeviceAPIClient

                public func callAsFunction(revision: Int, groupId: String, auditLogDetails: AuditLogDetails? = nil, groups: [String]? = nil, origin: Origin? = nil, users: [String]? = nil, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(revision: revision, groupId: groupId, auditLogDetails: auditLogDetails, groups: groups, origin: origin, users: users)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }

        public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response {
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var revokeItemGroupMembers: RevokeItemGroupMembers {
        RevokeItemGroupMembers(api: api)
    }
}

extension UserDeviceAPIClient.SharingUserdevice.RevokeItemGroupMembers {
        public struct Body: Encodable {

        private enum CodingKeys: String, CodingKey {
            case revision = "revision"
            case groupId = "groupId"
            case auditLogDetails = "auditLogDetails"
            case groups = "groups"
            case origin = "origin"
            case users = "users"
        }

                public let revision: Int

                public let groupId: String

        public let auditLogDetails: AuditLogDetails?

                public let groups: [String]?

                public let origin: Origin?

                public let users: [String]?
    }

        public enum Origin: String, Codable, Equatable, CaseIterable {
        case autoInvalid = "auto_invalid"
        case manual = "manual"
    }
}

extension UserDeviceAPIClient.SharingUserdevice.RevokeItemGroupMembers {
    public typealias Response = ServerResponse
}
