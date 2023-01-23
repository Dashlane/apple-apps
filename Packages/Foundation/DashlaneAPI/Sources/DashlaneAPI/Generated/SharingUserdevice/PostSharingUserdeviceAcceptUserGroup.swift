import Foundation
extension UserDeviceAPIClient.SharingUserdevice {
        public struct AcceptUserGroup {
        public static let endpoint: Endpoint = "/sharing-userdevice/AcceptUserGroup"

        public let api: UserDeviceAPIClient

                public func callAsFunction(provisioningMethod: ProvisioningMethod, revision: Int, groupId: String, acceptSignature: String, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(provisioningMethod: provisioningMethod, revision: revision, groupId: groupId, acceptSignature: acceptSignature)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var acceptUserGroup: AcceptUserGroup {
        AcceptUserGroup(api: api)
    }
}

extension UserDeviceAPIClient.SharingUserdevice.AcceptUserGroup {
        struct Body: Encodable {

        public let provisioningMethod: ProvisioningMethod

                public let revision: Int

                public let groupId: String

                public let acceptSignature: String
    }
}

extension UserDeviceAPIClient.SharingUserdevice.AcceptUserGroup {
    public typealias Response = ServerResponse
}
