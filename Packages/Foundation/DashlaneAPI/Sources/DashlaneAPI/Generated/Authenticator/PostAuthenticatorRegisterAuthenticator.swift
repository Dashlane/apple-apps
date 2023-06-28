import Foundation
extension UserDeviceAPIClient.Authenticator {
        public struct RegisterAuthenticator: APIRequest {
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
        public struct Body: Encodable {

        private enum CodingKeys: String, CodingKey {
            case push = "push"
        }

        public let push: Push?
    }

        public struct Push: Codable, Equatable {

                public enum Platform: String, Codable, Equatable, CaseIterable {
            case apn = "apn"
            case gcm = "gcm"
        }

        private enum CodingKeys: String, CodingKey {
            case pushId = "pushId"
            case platform = "platform"
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
