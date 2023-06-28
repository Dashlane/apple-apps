import Foundation
extension UserDeviceAPIClient.SharingUserdevice {
        public struct RenameUserGroup: APIRequest {
        public static let endpoint: Endpoint = "/sharing-userdevice/RenameUserGroup"

        public let api: UserDeviceAPIClient

                public func callAsFunction(provisioningMethod: ProvisioningMethod, revision: Int, groupId: String, name: String, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(provisioningMethod: provisioningMethod, revision: revision, groupId: groupId, name: name)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }

        public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response {
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var renameUserGroup: RenameUserGroup {
        RenameUserGroup(api: api)
    }
}

extension UserDeviceAPIClient.SharingUserdevice.RenameUserGroup {
        public struct Body: Encodable {

        private enum CodingKeys: String, CodingKey {
            case provisioningMethod = "provisioningMethod"
            case revision = "revision"
            case groupId = "groupId"
            case name = "name"
        }

        public let provisioningMethod: ProvisioningMethod

                public let revision: Int

                public let groupId: String

                public let name: String
    }
}

extension UserDeviceAPIClient.SharingUserdevice.RenameUserGroup {
    public typealias Response = ServerResponse
}
