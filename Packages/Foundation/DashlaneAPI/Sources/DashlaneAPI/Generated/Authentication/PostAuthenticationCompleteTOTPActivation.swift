import Foundation
extension UserDeviceAPIClient.Authentication {
        public struct CompleteTOTPActivation: APIRequest {
        public static let endpoint: Endpoint = "/authentication/CompleteTOTPActivation"

        public let api: UserDeviceAPIClient

                @discardableResult
        public func callAsFunction(authTicket: String, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(authTicket: authTicket)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var completeTOTPActivation: CompleteTOTPActivation {
        CompleteTOTPActivation(api: api)
    }
}

extension UserDeviceAPIClient.Authentication.CompleteTOTPActivation {
        public struct Body: Encodable {

        private enum CodingKeys: String, CodingKey {
            case authTicket = "authTicket"
        }

                public let authTicket: String
    }
}

extension UserDeviceAPIClient.Authentication.CompleteTOTPActivation {
    public typealias Response = Empty?
}
