import Foundation
extension UserDeviceAPIClient.SharingUserdevice {
        public struct RevokeUserGroupUsers: APIRequest {
        public static let endpoint: Endpoint = "/sharing-userdevice/RevokeUserGroupUsers"

        public let api: UserDeviceAPIClient

                public func callAsFunction(provisioningMethod: ProvisioningMethod, revision: Int, groupId: String, users: [String], timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(provisioningMethod: provisioningMethod, revision: revision, groupId: groupId, users: users)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }

        public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response {
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var revokeUserGroupUsers: RevokeUserGroupUsers {
        RevokeUserGroupUsers(api: api)
    }
}

extension UserDeviceAPIClient.SharingUserdevice.RevokeUserGroupUsers {
        public struct Body: Encodable {

        private enum CodingKeys: String, CodingKey {
            case provisioningMethod = "provisioningMethod"
            case revision = "revision"
            case groupId = "groupId"
            case users = "users"
        }

        public let provisioningMethod: ProvisioningMethod

                public let revision: Int

                public let groupId: String

                public let users: [String]
    }
}

extension UserDeviceAPIClient.SharingUserdevice.RevokeUserGroupUsers {
    public typealias Response = ServerResponse
}
