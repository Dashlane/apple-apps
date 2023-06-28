import Foundation
extension UserDeviceAPIClient.Authentication {
        public struct RequestExtraDeviceRegistration: APIRequest {
        public static let endpoint: Endpoint = "/authentication/RequestExtraDeviceRegistration"

        public let api: UserDeviceAPIClient

                public func callAsFunction(tokenType: TokenType, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(tokenType: tokenType)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var requestExtraDeviceRegistration: RequestExtraDeviceRegistration {
        RequestExtraDeviceRegistration(api: api)
    }
}

extension UserDeviceAPIClient.Authentication.RequestExtraDeviceRegistration {
        public struct Body: Encodable {

        private enum CodingKeys: String, CodingKey {
            case tokenType = "tokenType"
        }

        public let tokenType: TokenType
    }

        public enum TokenType: String, Codable, Equatable, CaseIterable {
        case shortLived = "shortLived"
        case googleAccountNewDevice = "googleAccountNewDevice"
    }
}

extension UserDeviceAPIClient.Authentication.RequestExtraDeviceRegistration {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

        private enum CodingKeys: String, CodingKey {
            case token = "token"
        }

        public let token: String

        public init(token: String) {
            self.token = token
        }
    }
}
