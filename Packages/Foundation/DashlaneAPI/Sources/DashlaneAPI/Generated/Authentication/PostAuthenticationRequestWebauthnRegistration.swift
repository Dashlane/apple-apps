import Foundation
extension UserDeviceAPIClient.Authentication {
        public struct RequestWebauthnRegistration {
        public static let endpoint: Endpoint = "/authentication/RequestWebauthnRegistration"

        public let api: UserDeviceAPIClient

                public func callAsFunction(timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body()
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var requestWebauthnRegistration: RequestWebauthnRegistration {
        RequestWebauthnRegistration(api: api)
    }
}

extension UserDeviceAPIClient.Authentication.RequestWebauthnRegistration {
        struct Body: Encodable {
    }
}

extension UserDeviceAPIClient.Authentication.RequestWebauthnRegistration {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

                public let challenge: String

                public let expirationDateUnix: Int

        public init(challenge: String, expirationDateUnix: Int) {
            self.challenge = challenge
            self.expirationDateUnix = expirationDateUnix
        }
    }
}
