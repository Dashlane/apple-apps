import Foundation
extension UserDeviceAPIClient.SharingUserdevice {
        public struct Get {
        public static let endpoint: Endpoint = "/sharing-userdevice/Get"

        public let api: UserDeviceAPIClient

                public func callAsFunction(itemGroupIds: [String]? = nil, itemIds: [String]? = nil, userGroupIds: [String]? = nil, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(itemGroupIds: itemGroupIds, itemIds: itemIds, userGroupIds: userGroupIds)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var get: Get {
        Get(api: api)
    }
}

extension UserDeviceAPIClient.SharingUserdevice.Get {
        struct Body: Encodable {

                public let itemGroupIds: [String]?

                public let itemIds: [String]?

                public let userGroupIds: [String]?
    }
}

extension UserDeviceAPIClient.SharingUserdevice.Get {
    public typealias Response = ServerResponse
}
