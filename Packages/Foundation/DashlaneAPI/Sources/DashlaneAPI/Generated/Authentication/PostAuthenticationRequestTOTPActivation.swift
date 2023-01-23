import Foundation
extension UserDeviceAPIClient.Authentication {
        public struct RequestTOTPActivation {
        public static let endpoint: Endpoint = "/authentication/RequestTOTPActivation"

        public let api: UserDeviceAPIClient

                public func callAsFunction(phoneNumber: String, country: String, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(phoneNumber: phoneNumber, country: country)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var requestTOTPActivation: RequestTOTPActivation {
        RequestTOTPActivation(api: api)
    }
}

extension UserDeviceAPIClient.Authentication.RequestTOTPActivation {
        struct Body: Encodable {

                public let phoneNumber: String

                public let country: String
    }
}

extension UserDeviceAPIClient.Authentication.RequestTOTPActivation {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

                public let seed: String

                public let serverKey: String

                public let uri: String

                public let recoveryKeys: [String]

        public init(seed: String, serverKey: String, uri: String, recoveryKeys: [String]) {
            self.seed = seed
            self.serverKey = serverKey
            self.uri = uri
            self.recoveryKeys = recoveryKeys
        }
    }
}
