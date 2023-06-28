import Foundation
extension UserDeviceAPIClient.SharingUserdevice {
        public struct CreateCollection: APIRequest {
        public static let endpoint: Endpoint = "/sharing-userdevice/CreateCollection"

        public let api: UserDeviceAPIClient

                public func callAsFunction(collectionUUID: String, collectionName: String, users: [UserCollectionUpload], publicKey: String, privateKey: String, userGroups: [UserGroupCollectionInvite]? = nil, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(collectionUUID: collectionUUID, collectionName: collectionName, users: users, publicKey: publicKey, privateKey: privateKey, userGroups: userGroups)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }

        public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response {
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var createCollection: CreateCollection {
        CreateCollection(api: api)
    }
}

extension UserDeviceAPIClient.SharingUserdevice.CreateCollection {
        public struct Body: Encodable {

        private enum CodingKeys: String, CodingKey {
            case collectionUUID = "collectionUUID"
            case collectionName = "collectionName"
            case users = "users"
            case publicKey = "publicKey"
            case privateKey = "privateKey"
            case userGroups = "userGroups"
        }

                public let collectionUUID: String

                public let collectionName: String

                public let users: [UserCollectionUpload]

                public let publicKey: String

                public let privateKey: String

                public let userGroups: [UserGroupCollectionInvite]?
    }
}

extension UserDeviceAPIClient.SharingUserdevice.CreateCollection {
    public typealias Response = ServerResponse
}
