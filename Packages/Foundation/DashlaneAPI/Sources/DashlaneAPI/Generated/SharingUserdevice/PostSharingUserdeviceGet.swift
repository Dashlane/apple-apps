import Foundation
extension UserDeviceAPIClient.SharingUserdevice {
        public struct Get: APIRequest {
        public static let endpoint: Endpoint = "/sharing-userdevice/Get"

        public let api: UserDeviceAPIClient

                public func callAsFunction(collectionIds: [String]? = nil, itemGroupIds: [String]? = nil, itemIds: [String]? = nil, userGroupIds: [String]? = nil, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(collectionIds: collectionIds, itemGroupIds: itemGroupIds, itemIds: itemIds, userGroupIds: userGroupIds)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }

        public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response {
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var get: Get {
        Get(api: api)
    }
}

extension UserDeviceAPIClient.SharingUserdevice.Get {
        public struct Body: Encodable {

        private enum CodingKeys: String, CodingKey {
            case collectionIds = "collectionIds"
            case itemGroupIds = "itemGroupIds"
            case itemIds = "itemIds"
            case userGroupIds = "userGroupIds"
        }

                public let collectionIds: [String]?

                public let itemGroupIds: [String]?

                public let itemIds: [String]?

                public let userGroupIds: [String]?
    }
}

extension UserDeviceAPIClient.SharingUserdevice.Get {
    public typealias Response = ServerResponse
}
