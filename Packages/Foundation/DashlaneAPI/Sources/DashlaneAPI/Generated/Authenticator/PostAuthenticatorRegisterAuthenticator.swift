import Foundation
extension UserDeviceAPIClient.Authenticator {
        public struct RegisterAuthenticator {
        public static let endpoint: Endpoint = "/authenticator/RegisterAuthenticator"

        public let api: UserDeviceAPIClient

                @discardableResult
        public func callAsFunction(push: Push? = nil, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(push: push)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var registerAuthenticator: RegisterAuthenticator {
        RegisterAuthenticator(api: api)
    }
}

extension UserDeviceAPIClient.Authenticator.RegisterAuthenticator {
        struct Body: Encodable {

        public let push: Push?
    }

        public struct Push: Codable, Equatable {

                public enum Platform: String, Codable, Equatable, CaseIterable {
            case apn = "apn"
            case gcm = "gcm"
        }

        public let pushId: String

        public let platform: Platform

        public init(pushId: String, platform: Platform) {
            self.pushId = pushId
            self.platform = platform
        }
    }
}

extension UserDeviceAPIClient.Authenticator.RegisterAuthenticator {
    public typealias Response = Empty?
}
