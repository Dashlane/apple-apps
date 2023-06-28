import Foundation
extension UserDeviceAPIClient.Vpn {
        public struct GetVPNSubscriptionInfo: APIRequest {
        public static let endpoint: Endpoint = "/vpn/GetVPNSubscriptionInfo"

        public let api: UserDeviceAPIClient

                public func callAsFunction(timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body()
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var getVPNSubscriptionInfo: GetVPNSubscriptionInfo {
        GetVPNSubscriptionInfo(api: api)
    }
}

extension UserDeviceAPIClient.Vpn.GetVPNSubscriptionInfo {
        public struct Body: Encodable {
    }
}

extension UserDeviceAPIClient.Vpn.GetVPNSubscriptionInfo {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

        private enum CodingKeys: String, CodingKey {
            case isSubscribed = "isSubscribed"
            case subscriptionDateUnix = "subscriptionDateUnix"
        }

                public let isSubscribed: Bool

                public let subscriptionDateUnix: Int?

        public init(isSubscribed: Bool, subscriptionDateUnix: Int? = nil) {
            self.isSubscribed = isSubscribed
            self.subscriptionDateUnix = subscriptionDateUnix
        }
    }
}
