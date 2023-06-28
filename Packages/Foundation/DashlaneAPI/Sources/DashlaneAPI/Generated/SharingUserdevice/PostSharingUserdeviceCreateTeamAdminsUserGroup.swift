import Foundation
extension UserDeviceAPIClient.SharingUserdevice {
        public struct CreateTeamAdminsUserGroup: APIRequest {
        public static let endpoint: Endpoint = "/sharing-userdevice/CreateTeamAdminsUserGroup"

        public let api: UserDeviceAPIClient

                public func callAsFunction(provisioningMethod: ProvisioningMethod, groupId: String, teamId: Int, name: String, publicKey: String, privateKey: String, users: [UserUpload], timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(provisioningMethod: provisioningMethod, groupId: groupId, teamId: teamId, name: name, publicKey: publicKey, privateKey: privateKey, users: users)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }

        public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response {
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var createTeamAdminsUserGroup: CreateTeamAdminsUserGroup {
        CreateTeamAdminsUserGroup(api: api)
    }
}

extension UserDeviceAPIClient.SharingUserdevice.CreateTeamAdminsUserGroup {
        public struct Body: Encodable {

        private enum CodingKeys: String, CodingKey {
            case provisioningMethod = "provisioningMethod"
            case groupId = "groupId"
            case teamId = "teamId"
            case name = "name"
            case publicKey = "publicKey"
            case privateKey = "privateKey"
            case users = "users"
        }

        public let provisioningMethod: ProvisioningMethod

                public let groupId: String

                public let teamId: Int

                public let name: String

                public let publicKey: String

                public let privateKey: String

                public let users: [UserUpload]
    }
}

extension UserDeviceAPIClient.SharingUserdevice.CreateTeamAdminsUserGroup {
    public typealias Response = ServerResponse
}
