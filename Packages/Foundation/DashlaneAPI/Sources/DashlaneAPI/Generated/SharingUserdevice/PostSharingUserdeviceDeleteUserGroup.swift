import Foundation
extension UserDeviceAPIClient.SharingUserdevice {
        public struct DeleteUserGroup: APIRequest {
        public static let endpoint: Endpoint = "/sharing-userdevice/DeleteUserGroup"

        public let api: UserDeviceAPIClient

                public func callAsFunction(provisioningMethod: ProvisioningMethod, groupId: String, revision: Int, groupKeyItem: UserGroupKeyItemDetails? = nil, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(provisioningMethod: provisioningMethod, groupId: groupId, revision: revision, groupKeyItem: groupKeyItem)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }

        public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response {
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var deleteUserGroup: DeleteUserGroup {
        DeleteUserGroup(api: api)
    }
}

extension UserDeviceAPIClient.SharingUserdevice.DeleteUserGroup {
        public struct Body: Encodable {

        private enum CodingKeys: String, CodingKey {
            case provisioningMethod = "provisioningMethod"
            case groupId = "groupId"
            case revision = "revision"
            case groupKeyItem = "groupKeyItem"
        }

        public let provisioningMethod: ProvisioningMethod

                public let groupId: String

                public let revision: Int

        public let groupKeyItem: UserGroupKeyItemDetails?
    }
}

extension UserDeviceAPIClient.SharingUserdevice.DeleteUserGroup {
    public typealias Response = ServerResponse
}
