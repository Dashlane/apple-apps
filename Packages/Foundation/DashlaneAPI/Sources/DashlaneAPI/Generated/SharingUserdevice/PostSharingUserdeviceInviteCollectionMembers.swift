import Foundation
extension UserDeviceAPIClient.SharingUserdevice {
        public struct InviteCollectionMembers: APIRequest {
        public static let endpoint: Endpoint = "/sharing-userdevice/InviteCollectionMembers"

        public let api: UserDeviceAPIClient

                public func callAsFunction(revision: Int, collectionUUID: String, userGroups: [UserGroupCollectionInvite]? = nil, users: [UserCollectionUpload]? = nil, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(revision: revision, collectionUUID: collectionUUID, userGroups: userGroups, users: users)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }

        public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response {
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var inviteCollectionMembers: InviteCollectionMembers {
        InviteCollectionMembers(api: api)
    }
}

extension UserDeviceAPIClient.SharingUserdevice.InviteCollectionMembers {
        public struct Body: Encodable {

        private enum CodingKeys: String, CodingKey {
            case revision = "revision"
            case collectionUUID = "collectionUUID"
            case userGroups = "userGroups"
            case users = "users"
        }

                public let revision: Int

                public let collectionUUID: String

                public let userGroups: [UserGroupCollectionInvite]?

                public let users: [UserCollectionUpload]?
    }
}

extension UserDeviceAPIClient.SharingUserdevice.InviteCollectionMembers {
    public typealias Response = ServerResponse
}
