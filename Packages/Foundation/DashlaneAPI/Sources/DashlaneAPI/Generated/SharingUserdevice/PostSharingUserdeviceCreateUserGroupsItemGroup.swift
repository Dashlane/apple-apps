import Foundation
extension UserDeviceAPIClient.SharingUserdevice {
        public struct CreateUserGroupsItemGroup {
        public static let endpoint: Endpoint = "/sharing-userdevice/CreateUserGroupsItemGroup"

        public let api: UserDeviceAPIClient

                public func callAsFunction(groupId: String, teamId: Int, alias: String, groups: [UserGroupInvite], items: [ItemUpload]? = nil, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(groupId: groupId, teamId: teamId, alias: alias, groups: groups, items: items)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var createUserGroupsItemGroup: CreateUserGroupsItemGroup {
        CreateUserGroupsItemGroup(api: api)
    }
}

extension UserDeviceAPIClient.SharingUserdevice.CreateUserGroupsItemGroup {
        struct Body: Encodable {

                public let groupId: String

                public let teamId: Int

                public let alias: String

                public let groups: [UserGroupInvite]

                public let items: [ItemUpload]?
    }
}

extension UserDeviceAPIClient.SharingUserdevice.CreateUserGroupsItemGroup {
    public typealias Response = ServerResponse
}
