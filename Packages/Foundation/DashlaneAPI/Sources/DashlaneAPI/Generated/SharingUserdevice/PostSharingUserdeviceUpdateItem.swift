import Foundation
extension UserDeviceAPIClient.SharingUserdevice {
        public struct UpdateItem {
        public static let endpoint: Endpoint = "/sharing-userdevice/UpdateItem"

        public let api: UserDeviceAPIClient

                public func callAsFunction(itemId: String, content: String, timestamp: Int, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(itemId: itemId, content: content, timestamp: timestamp)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var updateItem: UpdateItem {
        UpdateItem(api: api)
    }
}

extension UserDeviceAPIClient.SharingUserdevice.UpdateItem {
        struct Body: Encodable {

                public let itemId: String

                public let content: String

                public let timestamp: Int
    }
}

extension UserDeviceAPIClient.SharingUserdevice.UpdateItem {
    public typealias Response = ServerResponse
}
