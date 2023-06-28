import Foundation
extension UserDeviceAPIClient.Authentication {
        public struct Get2FAStatus: APIRequest {
        public static let endpoint: Endpoint = "/authentication/Get2FAStatus"

        public let api: UserDeviceAPIClient

                public func callAsFunction(timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body()
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var get2FAStatus: Get2FAStatus {
        Get2FAStatus(api: api)
    }
}

extension UserDeviceAPIClient.Authentication.Get2FAStatus {
        public struct Body: Encodable {
    }
}

extension UserDeviceAPIClient.Authentication.Get2FAStatus {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

        private enum CodingKeys: String, CodingKey {
            case type = "type"
            case lastUpdateDateUnix = "lastUpdateDateUnix"
            case recoveryPhone = "recoveryPhone"
            case isDuoEnabled = "isDuoEnabled"
            case hasU2FKeys = "hasU2FKeys"
            case ssoInfo = "ssoInfo"
        }

        public let type: AuthenticationGet2FAStatusType

                public let lastUpdateDateUnix: Int?

                public let recoveryPhone: String?

                public let isDuoEnabled: Bool

                public let hasU2FKeys: Bool

        public let ssoInfo: AuthenticationSsoInfo?

        public init(type: AuthenticationGet2FAStatusType, lastUpdateDateUnix: Int?, recoveryPhone: String?, isDuoEnabled: Bool, hasU2FKeys: Bool, ssoInfo: AuthenticationSsoInfo? = nil) {
            self.type = type
            self.lastUpdateDateUnix = lastUpdateDateUnix
            self.recoveryPhone = recoveryPhone
            self.isDuoEnabled = isDuoEnabled
            self.hasU2FKeys = hasU2FKeys
            self.ssoInfo = ssoInfo
        }
    }
}
