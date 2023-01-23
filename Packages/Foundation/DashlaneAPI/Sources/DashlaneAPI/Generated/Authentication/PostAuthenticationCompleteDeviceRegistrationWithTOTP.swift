import Foundation
extension AppAPIClient.Authentication {
        public struct CompleteDeviceRegistrationWithTOTP {
        public static let endpoint: Endpoint = "/authentication/CompleteDeviceRegistrationWithTOTP"

        public let api: AppAPIClient

                public func callAsFunction(device: AuthenticationCompleteDeviceRegistrationDevice, login: String, verification: AuthenticationCompleteWithTOPVerification, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(device: device, login: login, verification: verification)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var completeDeviceRegistrationWithTOTP: CompleteDeviceRegistrationWithTOTP {
        CompleteDeviceRegistrationWithTOTP(api: api)
    }
}

extension AppAPIClient.Authentication.CompleteDeviceRegistrationWithTOTP {
        struct Body: Encodable {

        public let device: AuthenticationCompleteDeviceRegistrationDevice

                public let login: String

        public let verification: AuthenticationCompleteWithTOPVerification
    }
}

extension AppAPIClient.Authentication.CompleteDeviceRegistrationWithTOTP {
    public typealias Response = AuthenticationCompleteDeviceRegistrationResponse
}
