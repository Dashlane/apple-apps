import Foundation
extension UserDeviceAPIClient.SharingUserdevice {
        public struct RefuseUserGroup {
        public static let endpoint: Endpoint = "/sharing-userdevice/RefuseUserGroup"

        public let api: UserDeviceAPIClient

                public func callAsFunction(provisioningMethod: ProvisioningMethod, revision: Int, groupId: String, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(provisioningMethod: provisioningMethod, revision: revision, groupId: groupId)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var refuseUserGroup: RefuseUserGroup {
        RefuseUserGroup(api: api)
    }
}

extension UserDeviceAPIClient.SharingUserdevice.RefuseUserGroup {
        struct Body: Encodable {

        public let provisioningMethod: ProvisioningMethod

                public let revision: Int

                public let groupId: String
    }
}

extension UserDeviceAPIClient.SharingUserdevice.RefuseUserGroup {
    public typealias Response = ServerResponse
}
