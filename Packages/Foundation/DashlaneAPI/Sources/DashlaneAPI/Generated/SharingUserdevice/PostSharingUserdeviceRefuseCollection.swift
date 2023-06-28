import Foundation
extension UserDeviceAPIClient.SharingUserdevice {
        public struct RefuseCollection: APIRequest {
        public static let endpoint: Endpoint = "/sharing-userdevice/RefuseCollection"

        public let api: UserDeviceAPIClient

                public func callAsFunction(revision: Int, collectionUUID: String, userGroupUUID: String? = nil, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(revision: revision, collectionUUID: collectionUUID, userGroupUUID: userGroupUUID)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var refuseCollection: RefuseCollection {
        RefuseCollection(api: api)
    }
}

extension UserDeviceAPIClient.SharingUserdevice.RefuseCollection {
        public struct Body: Encodable {

        private enum CodingKeys: String, CodingKey {
            case revision = "revision"
            case collectionUUID = "collectionUUID"
            case userGroupUUID = "userGroupUUID"
        }

                public let revision: Int

                public let collectionUUID: String

                public let userGroupUUID: String?
    }
}

extension UserDeviceAPIClient.SharingUserdevice.RefuseCollection {
    public typealias Response = ServerResponse
}
