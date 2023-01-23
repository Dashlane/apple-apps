import Foundation
extension UserDeviceAPIClient.Authentication {
        public struct DeactivateU2FDevice {
        public static let endpoint: Endpoint = "/authentication/DeactivateU2FDevice"

        public let api: UserDeviceAPIClient

                @discardableResult
        public func callAsFunction(authTicket: String, keyHandle: String, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(authTicket: authTicket, keyHandle: keyHandle)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var deactivateU2FDevice: DeactivateU2FDevice {
        DeactivateU2FDevice(api: api)
    }
}

extension UserDeviceAPIClient.Authentication.DeactivateU2FDevice {
        struct Body: Encodable {

                public let authTicket: String

                public let keyHandle: String
    }
}

extension UserDeviceAPIClient.Authentication.DeactivateU2FDevice {
    public typealias Response = Empty?
}
