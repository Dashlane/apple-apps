import Foundation
extension UserDeviceAPIClient.SharingUserdevice {
        public struct AddItemGroupsToCollection: APIRequest {
        public static let endpoint: Endpoint = "/sharing-userdevice/AddItemGroupsToCollection"

        public let api: UserDeviceAPIClient

                public func callAsFunction(revision: Int, collectionUUID: String, itemGroups: [ItemGroups], timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(revision: revision, collectionUUID: collectionUUID, itemGroups: itemGroups)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var addItemGroupsToCollection: AddItemGroupsToCollection {
        AddItemGroupsToCollection(api: api)
    }
}

extension UserDeviceAPIClient.SharingUserdevice.AddItemGroupsToCollection {
        public struct Body: Encodable {

        private enum CodingKeys: String, CodingKey {
            case revision = "revision"
            case collectionUUID = "collectionUUID"
            case itemGroups = "itemGroups"
        }

                public let revision: Int

                public let collectionUUID: String

                public let itemGroups: [ItemGroups]
    }

        public struct ItemGroups: Codable, Equatable {

                public enum Permission: String, Codable, Equatable, CaseIterable {
            case admin = "admin"
        }

        private enum CodingKeys: String, CodingKey {
            case uuid = "uuid"
            case permission = "permission"
            case itemGroupKey = "itemGroupKey"
            case proposeSignature = "proposeSignature"
            case acceptSignature = "acceptSignature"
        }

        public let uuid: String

                public let permission: Permission

                public let itemGroupKey: String

                public let proposeSignature: String

                public let acceptSignature: String

        public init(uuid: String, permission: Permission, itemGroupKey: String, proposeSignature: String, acceptSignature: String) {
            self.uuid = uuid
            self.permission = permission
            self.itemGroupKey = itemGroupKey
            self.proposeSignature = proposeSignature
            self.acceptSignature = acceptSignature
        }
    }
}

extension UserDeviceAPIClient.SharingUserdevice.AddItemGroupsToCollection {
    public typealias Response = ServerResponse
}
