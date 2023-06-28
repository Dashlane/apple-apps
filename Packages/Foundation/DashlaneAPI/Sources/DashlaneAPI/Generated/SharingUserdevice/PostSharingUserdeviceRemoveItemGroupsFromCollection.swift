import Foundation
extension UserDeviceAPIClient.SharingUserdevice {
        public struct RemoveItemGroupsFromCollection: APIRequest {
        public static let endpoint: Endpoint = "/sharing-userdevice/RemoveItemGroupsFromCollection"

        public let api: UserDeviceAPIClient

                public func callAsFunction(revision: Int, collectionUUID: String, itemGroupUUIDs: [String], timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(revision: revision, collectionUUID: collectionUUID, itemGroupUUIDs: itemGroupUUIDs)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var removeItemGroupsFromCollection: RemoveItemGroupsFromCollection {
        RemoveItemGroupsFromCollection(api: api)
    }
}

extension UserDeviceAPIClient.SharingUserdevice.RemoveItemGroupsFromCollection {
        public struct Body: Encodable {

        private enum CodingKeys: String, CodingKey {
            case revision = "revision"
            case collectionUUID = "collectionUUID"
            case itemGroupUUIDs = "itemGroupUUIDs"
        }

                public let revision: Int

                public let collectionUUID: String

                public let itemGroupUUIDs: [String]
    }
}

extension UserDeviceAPIClient.SharingUserdevice.RemoveItemGroupsFromCollection {
    public typealias Response = ServerResponse
}
