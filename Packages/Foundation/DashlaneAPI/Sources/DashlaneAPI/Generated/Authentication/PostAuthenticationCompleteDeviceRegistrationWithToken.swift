import Foundation
extension AppAPIClient.Authentication {
        public struct CompleteDeviceRegistrationWithToken {
        public static let endpoint: Endpoint = "/authentication/CompleteDeviceRegistrationWithToken"

        public let api: AppAPIClient

                public func callAsFunction(device: AuthenticationCompleteDeviceRegistrationDevice, login: String, verification: Verification, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(device: device, login: login, verification: verification)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var completeDeviceRegistrationWithToken: CompleteDeviceRegistrationWithToken {
        CompleteDeviceRegistrationWithToken(api: api)
    }
}

extension AppAPIClient.Authentication.CompleteDeviceRegistrationWithToken {
        struct Body: Encodable {

        public let device: AuthenticationCompleteDeviceRegistrationDevice

                public let login: String

        public let verification: Verification
    }

        public struct Verification: Codable, Equatable {

                public let token: String

        public init(token: String) {
            self.token = token
        }
    }
}

extension AppAPIClient.Authentication.CompleteDeviceRegistrationWithToken {
    public typealias Response = AuthenticationCompleteDeviceRegistrationResponse
}
