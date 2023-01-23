import Foundation
extension UserDeviceAPIClient.SharingUserdevice {
        public struct RemoveItems {
        public static let endpoint: Endpoint = "/sharing-userdevice/RemoveItems"

        public let api: UserDeviceAPIClient

                public func callAsFunction(revision: Int, groupId: String, items: [String], timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(revision: revision, groupId: groupId, items: items)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var removeItems: RemoveItems {
        RemoveItems(api: api)
    }
}

extension UserDeviceAPIClient.SharingUserdevice.RemoveItems {
        struct Body: Encodable {

                public let revision: Int

                public let groupId: String

                public let items: [String]
    }
}

extension UserDeviceAPIClient.SharingUserdevice.RemoveItems {
    public typealias Response = ServerResponse
}
