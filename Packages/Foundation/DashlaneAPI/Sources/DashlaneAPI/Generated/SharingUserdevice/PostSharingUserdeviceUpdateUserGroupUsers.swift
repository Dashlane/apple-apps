import Foundation
extension UserDeviceAPIClient.SharingUserdevice {
        public struct UpdateUserGroupUsers {
        public static let endpoint: Endpoint = "/sharing-userdevice/UpdateUserGroupUsers"

        public let api: UserDeviceAPIClient

                public func callAsFunction(revision: Int, groupId: String, users: [UserUpdate], timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(revision: revision, groupId: groupId, users: users)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var updateUserGroupUsers: UpdateUserGroupUsers {
        UpdateUserGroupUsers(api: api)
    }
}

extension UserDeviceAPIClient.SharingUserdevice.UpdateUserGroupUsers {
        struct Body: Encodable {

                public let revision: Int

                public let groupId: String

                public let users: [UserUpdate]
    }
}

extension UserDeviceAPIClient.SharingUserdevice.UpdateUserGroupUsers {
    public typealias Response = ServerResponse
}
