import Foundation
extension UserDeviceAPIClient.SharingUserdevice {
        public struct UpdateItemGroupMembers: APIRequest {
        public static let endpoint: Endpoint = "/sharing-userdevice/UpdateItemGroupMembers"

        public let api: UserDeviceAPIClient

                public func callAsFunction(revision: Int, groupId: String, groups: [UserGroupUpdate]? = nil, users: [UserUpdate]? = nil, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(revision: revision, groupId: groupId, groups: groups, users: users)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }

        public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response {
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var updateItemGroupMembers: UpdateItemGroupMembers {
        UpdateItemGroupMembers(api: api)
    }
}

extension UserDeviceAPIClient.SharingUserdevice.UpdateItemGroupMembers {
        public struct Body: Encodable {

        private enum CodingKeys: String, CodingKey {
            case revision = "revision"
            case groupId = "groupId"
            case groups = "groups"
            case users = "users"
        }

                public let revision: Int

                public let groupId: String

                public let groups: [UserGroupUpdate]?

                public let users: [UserUpdate]?
    }
}

extension UserDeviceAPIClient.SharingUserdevice.UpdateItemGroupMembers {
    public typealias Response = ServerResponse
}
