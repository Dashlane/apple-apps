import Foundation
extension UserDeviceAPIClient.Authentication {
        public struct UpdateRecoveryPhoneNumber {
        public static let endpoint: Endpoint = "/authentication/UpdateRecoveryPhoneNumber"

        public let api: UserDeviceAPIClient

                public func callAsFunction(authTicket: String, phoneNumber: String, country: String, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(authTicket: authTicket, phoneNumber: phoneNumber, country: country)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var updateRecoveryPhoneNumber: UpdateRecoveryPhoneNumber {
        UpdateRecoveryPhoneNumber(api: api)
    }
}

extension UserDeviceAPIClient.Authentication.UpdateRecoveryPhoneNumber {
        struct Body: Encodable {

                public let authTicket: String

                public let phoneNumber: String

                public let country: String
    }
}

extension UserDeviceAPIClient.Authentication.UpdateRecoveryPhoneNumber {
    public typealias Response = Empty?
}
