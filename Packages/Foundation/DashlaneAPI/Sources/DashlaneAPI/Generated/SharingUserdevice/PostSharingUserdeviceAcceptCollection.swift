import Foundation
extension UserDeviceAPIClient.SharingUserdevice {
        public struct AcceptCollection: APIRequest {
        public static let endpoint: Endpoint = "/sharing-userdevice/AcceptCollection"

        public let api: UserDeviceAPIClient

                public func callAsFunction(revision: Int, collectionUUID: String, acceptSignature: String, userGroupUUID: String? = nil, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(revision: revision, collectionUUID: collectionUUID, acceptSignature: acceptSignature, userGroupUUID: userGroupUUID)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }

        public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response {
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var acceptCollection: AcceptCollection {
        AcceptCollection(api: api)
    }
}

extension UserDeviceAPIClient.SharingUserdevice.AcceptCollection {
        public struct Body: Encodable {

        private enum CodingKeys: String, CodingKey {
            case revision = "revision"
            case collectionUUID = "collectionUUID"
            case acceptSignature = "acceptSignature"
            case userGroupUUID = "userGroupUUID"
        }

                public let revision: Int

                public let collectionUUID: String

                public let acceptSignature: String

                public let userGroupUUID: String?
    }
}

extension UserDeviceAPIClient.SharingUserdevice.AcceptCollection {
    public typealias Response = ServerResponse
}
