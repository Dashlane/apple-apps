import Foundation
extension UserDeviceAPIClient.Authentication {
        public struct GetRecoveryPhoneNumber {
        public static let endpoint: Endpoint = "/authentication/GetRecoveryPhoneNumber"

        public let api: UserDeviceAPIClient

                public func callAsFunction(timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body()
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var getRecoveryPhoneNumber: GetRecoveryPhoneNumber {
        GetRecoveryPhoneNumber(api: api)
    }
}

extension UserDeviceAPIClient.Authentication.GetRecoveryPhoneNumber {
        struct Body: Encodable {
    }
}

extension UserDeviceAPIClient.Authentication.GetRecoveryPhoneNumber {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

                public let recoveryPhoneNumber: String

        public init(recoveryPhoneNumber: String) {
            self.recoveryPhoneNumber = recoveryPhoneNumber
        }
    }
}
