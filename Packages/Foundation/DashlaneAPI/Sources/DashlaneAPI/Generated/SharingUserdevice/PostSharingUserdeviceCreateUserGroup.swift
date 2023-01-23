import Foundation
extension UserDeviceAPIClient.SharingUserdevice {
        public struct CreateUserGroup {
        public static let endpoint: Endpoint = "/sharing-userdevice/CreateUserGroup"

        public let api: UserDeviceAPIClient

                public func callAsFunction(provisioningMethod: ProvisioningMethod, groupId: String, teamId: Int, name: String, publicKey: String, privateKey: String, users: [InviteUserGroupUserUpload], externalId: String? = nil, groupKeyItem: UserGroupKeyItemUpload? = nil, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(provisioningMethod: provisioningMethod, groupId: groupId, teamId: teamId, name: name, publicKey: publicKey, privateKey: privateKey, users: users, externalId: externalId, groupKeyItem: groupKeyItem)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var createUserGroup: CreateUserGroup {
        CreateUserGroup(api: api)
    }
}

extension UserDeviceAPIClient.SharingUserdevice.CreateUserGroup {
        struct Body: Encodable {

        public let provisioningMethod: ProvisioningMethod

                public let groupId: String

                public let teamId: Int

                public let name: String

                public let publicKey: String

                public let privateKey: String

                public let users: [InviteUserGroupUserUpload]

                public let externalId: String?

        public let groupKeyItem: UserGroupKeyItemUpload?
    }
}

extension UserDeviceAPIClient.SharingUserdevice.CreateUserGroup {
    public typealias Response = ServerResponse
}
