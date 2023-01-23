import Foundation
extension AppAPIClient.Authentication {
        public struct CompleteExtraDeviceRegistrationWithToken {
        public static let endpoint: Endpoint = "/authentication/CompleteExtraDeviceRegistrationWithToken"

        public let api: AppAPIClient

                public func callAsFunction(device: AuthenticationCompleteDeviceRegistrationDevice, login: String, verification: Verification, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(device: device, login: login, verification: verification)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var completeExtraDeviceRegistrationWithToken: CompleteExtraDeviceRegistrationWithToken {
        CompleteExtraDeviceRegistrationWithToken(api: api)
    }
}

extension AppAPIClient.Authentication.CompleteExtraDeviceRegistrationWithToken {
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

extension AppAPIClient.Authentication.CompleteExtraDeviceRegistrationWithToken {
    public typealias Response = AuthenticationCompleteDeviceRegistrationResponse
}
