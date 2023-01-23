import Foundation
extension AppAPIClient.Authentication {
        public struct CompleteLoginWithTOTP {
        public static let endpoint: Endpoint = "/authentication/CompleteLoginWithTOTP"

        public let api: AppAPIClient

                public func callAsFunction(login: String, deviceAccessKey: String, verification: AuthenticationCompleteWithTOPVerification, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(login: login, deviceAccessKey: deviceAccessKey, verification: verification)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var completeLoginWithTOTP: CompleteLoginWithTOTP {
        CompleteLoginWithTOTP(api: api)
    }
}

extension AppAPIClient.Authentication.CompleteLoginWithTOTP {
        struct Body: Encodable {

                public let login: String

                public let deviceAccessKey: String

        public let verification: AuthenticationCompleteWithTOPVerification
    }
}

extension AppAPIClient.Authentication.CompleteLoginWithTOTP {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

                public let serverKey: String

        public init(serverKey: String) {
            self.serverKey = serverKey
        }
    }
}
