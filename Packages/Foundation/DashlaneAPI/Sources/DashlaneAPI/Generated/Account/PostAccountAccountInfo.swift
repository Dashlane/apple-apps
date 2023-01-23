import Foundation
extension UserDeviceAPIClient.Account {
        public struct AccountInfo {
        public static let endpoint: Endpoint = "/account/AccountInfo"

        public let api: UserDeviceAPIClient

                public func callAsFunction(timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body()
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var accountInfo: AccountInfo {
        AccountInfo(api: api)
    }
}

extension UserDeviceAPIClient.Account.AccountInfo {
        struct Body: Encodable {
    }
}

extension UserDeviceAPIClient.Account.AccountInfo {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

                public let creationDateUnix: Int

                public let publicUserId: String

                public let deviceAnalyticsId: String?

                public let userAnalyticsId: String?

        public init(creationDateUnix: Int, publicUserId: String, deviceAnalyticsId: String? = nil, userAnalyticsId: String? = nil) {
            self.creationDateUnix = creationDateUnix
            self.publicUserId = publicUserId
            self.deviceAnalyticsId = deviceAnalyticsId
            self.userAnalyticsId = userAnalyticsId
        }
    }
}
