import Foundation
extension UserDeviceAPIClient.SharingUserdevice {
        public struct DeleteItemGroup {
        public static let endpoint: Endpoint = "/sharing-userdevice/DeleteItemGroup"

        public let api: UserDeviceAPIClient

                public func callAsFunction(groupId: String, revision: Int, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(groupId: groupId, revision: revision)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var deleteItemGroup: DeleteItemGroup {
        DeleteItemGroup(api: api)
    }
}

extension UserDeviceAPIClient.SharingUserdevice.DeleteItemGroup {
        struct Body: Encodable {

                public let groupId: String

                public let revision: Int
    }
}

extension UserDeviceAPIClient.SharingUserdevice.DeleteItemGroup {
    public typealias Response = ServerResponse
}
