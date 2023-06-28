import Foundation
extension UserDeviceAPIClient.Accountrecovery {
        public struct RequestActivation: APIRequest {
        public static let endpoint: Endpoint = "/accountrecovery/RequestActivation"

        public let api: UserDeviceAPIClient

                public func callAsFunction(encryptedVaultKey: String, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(encryptedVaultKey: encryptedVaultKey)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var requestActivation: RequestActivation {
        RequestActivation(api: api)
    }
}

extension UserDeviceAPIClient.Accountrecovery.RequestActivation {
        public struct Body: Encodable {

        private enum CodingKeys: String, CodingKey {
            case encryptedVaultKey = "encryptedVaultKey"
        }

                public let encryptedVaultKey: String
    }
}

extension UserDeviceAPIClient.Accountrecovery.RequestActivation {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

        private enum CodingKeys: String, CodingKey {
            case recoveryId = "recoveryId"
        }

                public let recoveryId: String

        public init(recoveryId: String) {
            self.recoveryId = recoveryId
        }
    }
}
