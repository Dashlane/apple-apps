import Foundation
extension UserDeviceAPIClient.Authentication {
        public struct DeactivateTOTP {
        public static let endpoint: Endpoint = "/authentication/DeactivateTOTP"

        public let api: UserDeviceAPIClient

                @discardableResult
        public func callAsFunction(authTicket: String, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(authTicket: authTicket)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var deactivateTOTP: DeactivateTOTP {
        DeactivateTOTP(api: api)
    }
}

extension UserDeviceAPIClient.Authentication.DeactivateTOTP {
        struct Body: Encodable {

                public let authTicket: String
    }
}

extension UserDeviceAPIClient.Authentication.DeactivateTOTP {
    public typealias Response = Empty?
}
