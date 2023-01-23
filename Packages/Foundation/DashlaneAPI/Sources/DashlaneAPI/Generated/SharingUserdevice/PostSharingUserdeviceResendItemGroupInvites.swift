import Foundation
extension UserDeviceAPIClient.SharingUserdevice {
        public struct ResendItemGroupInvites {
        public static let endpoint: Endpoint = "/sharing-userdevice/ResendItemGroupInvites"

        public let api: UserDeviceAPIClient

                public func callAsFunction(revision: Int, groupId: String, users: [UserInviteResend], itemsForEmailing: [ItemForEmailing]? = nil, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(revision: revision, groupId: groupId, users: users, itemsForEmailing: itemsForEmailing)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var resendItemGroupInvites: ResendItemGroupInvites {
        ResendItemGroupInvites(api: api)
    }
}

extension UserDeviceAPIClient.SharingUserdevice.ResendItemGroupInvites {
        struct Body: Encodable {

                public let revision: Int

                public let groupId: String

                public let users: [UserInviteResend]

                public let itemsForEmailing: [ItemForEmailing]?
    }
}

extension UserDeviceAPIClient.SharingUserdevice.ResendItemGroupInvites {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

        public let result: String

        public init(result: String) {
            self.result = result
        }
    }
}
