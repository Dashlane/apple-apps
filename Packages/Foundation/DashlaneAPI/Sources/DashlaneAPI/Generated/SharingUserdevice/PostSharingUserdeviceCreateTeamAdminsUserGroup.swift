import Foundation
extension UserDeviceAPIClient.SharingUserdevice {
        public struct CreateTeamAdminsUserGroup {
        public static let endpoint: Endpoint = "/sharing-userdevice/CreateTeamAdminsUserGroup"

        public let api: UserDeviceAPIClient

                public func callAsFunction(provisioningMethod: ProvisioningMethod, groupId: String, teamId: Int, name: String, publicKey: String, privateKey: String, users: [UserUpload], timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(provisioningMethod: provisioningMethod, groupId: groupId, teamId: teamId, name: name, publicKey: publicKey, privateKey: privateKey, users: users)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var createTeamAdminsUserGroup: CreateTeamAdminsUserGroup {
        CreateTeamAdminsUserGroup(api: api)
    }
}

extension UserDeviceAPIClient.SharingUserdevice.CreateTeamAdminsUserGroup {
        struct Body: Encodable {

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
