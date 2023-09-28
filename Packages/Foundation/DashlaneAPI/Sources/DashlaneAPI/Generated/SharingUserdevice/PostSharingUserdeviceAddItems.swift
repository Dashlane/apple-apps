import Foundation
extension UserDeviceAPIClient.SharingUserdevice {
        public struct AddItems: APIRequest {
        public static let endpoint: Endpoint = "/sharing-userdevice/AddItems"

        public let api: UserDeviceAPIClient

                public func callAsFunction(revision: Int, groupId: String, items: [ItemUpload], timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(revision: revision, groupId: groupId, items: items)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var addItems: AddItems {
        AddItems(api: api)
    }
}

extension UserDeviceAPIClient.SharingUserdevice.AddItems {
        public struct Body: Encodable {

        private enum CodingKeys: String, CodingKey {
            case revision = "revision"
            case groupId = "groupId"
            case items = "items"
        }

                public let revision: Int

                public let groupId: String

                public let items: [ItemUpload]
    }
}

extension UserDeviceAPIClient.SharingUserdevice.AddItems {
    public typealias Response = ServerResponse
}
