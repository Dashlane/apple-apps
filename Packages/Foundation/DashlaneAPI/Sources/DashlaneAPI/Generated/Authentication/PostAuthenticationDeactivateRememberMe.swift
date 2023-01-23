import Foundation
extension UserDeviceAPIClient.Authentication {
        public struct DeactivateRememberMe {
        public static let endpoint: Endpoint = "/authentication/DeactivateRememberMe"

        public let api: UserDeviceAPIClient

                @discardableResult
        public func callAsFunction(deviceAccessKey: String, removeAssociatedLocalAuthenticators: Bool? = nil, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(deviceAccessKey: deviceAccessKey, removeAssociatedLocalAuthenticators: removeAssociatedLocalAuthenticators)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var deactivateRememberMe: DeactivateRememberMe {
        DeactivateRememberMe(api: api)
    }
}

extension UserDeviceAPIClient.Authentication.DeactivateRememberMe {
        struct Body: Encodable {

                public let deviceAccessKey: String

                public let removeAssociatedLocalAuthenticators: Bool?
    }
}

extension UserDeviceAPIClient.Authentication.DeactivateRememberMe {
    public typealias Response = Empty?
}
