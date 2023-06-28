import Foundation
extension UserDeviceAPIClient.SharingUserdevice {
        public struct DeleteCollection: APIRequest {
        public static let endpoint: Endpoint = "/sharing-userdevice/DeleteCollection"

        public let api: UserDeviceAPIClient

                public func callAsFunction(collectionUUID: String, revision: Int, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(collectionUUID: collectionUUID, revision: revision)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var deleteCollection: DeleteCollection {
        DeleteCollection(api: api)
    }
}

extension UserDeviceAPIClient.SharingUserdevice.DeleteCollection {
        public struct Body: Encodable {

        private enum CodingKeys: String, CodingKey {
            case collectionUUID = "collectionUUID"
            case revision = "revision"
        }

                public let collectionUUID: String

                public let revision: Int
    }
}

extension UserDeviceAPIClient.SharingUserdevice.DeleteCollection {
    public typealias Response = ServerResponse
}
