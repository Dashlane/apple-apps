import Foundation
extension UserDeviceAPIClient.SharingUserdevice {
        public struct ResendItemGroupInvites: APIRequest {
        public static let endpoint: Endpoint = "/sharing-userdevice/ResendItemGroupInvites"

        public let api: UserDeviceAPIClient

                public func callAsFunction(revision: Int, groupId: String, users: [UserInviteResend], itemsForEmailing: [ItemForEmailing]? = nil, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(revision: revision, groupId: groupId, users: users, itemsForEmailing: itemsForEmailing)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }

        public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response {
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var resendItemGroupInvites: ResendItemGroupInvites {
        ResendItemGroupInvites(api: api)
    }
}

extension UserDeviceAPIClient.SharingUserdevice.ResendItemGroupInvites {
        public struct Body: Encodable {

        private enum CodingKeys: String, CodingKey {
            case revision = "revision"
            case groupId = "groupId"
            case users = "users"
            case itemsForEmailing = "itemsForEmailing"
        }

                public let revision: Int

                public let groupId: String

                public let users: [UserInviteResend]

                public let itemsForEmailing: [ItemForEmailing]?
    }
}

extension UserDeviceAPIClient.SharingUserdevice.ResendItemGroupInvites {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

        private enum CodingKeys: String, CodingKey {
            case result = "result"
        }

        public let result: String

        public init(result: String) {
            self.result = result
        }
    }
}
