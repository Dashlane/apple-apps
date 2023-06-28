import Foundation
extension UserDeviceAPIClient.Accountrecovery {
        public struct Deactivate: APIRequest {
        public static let endpoint: Endpoint = "/accountrecovery/Deactivate"

        public let api: UserDeviceAPIClient

                @discardableResult
        public func callAsFunction(reason: Reason, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(reason: reason)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var deactivate: Deactivate {
        Deactivate(api: api)
    }
}

extension UserDeviceAPIClient.Accountrecovery.Deactivate {
        public struct Body: Encodable {

        private enum CodingKeys: String, CodingKey {
            case reason = "reason"
        }

                public let reason: Reason
    }

        public enum Reason: String, Codable, Equatable, CaseIterable {
        case settings = "SETTINGS"
        case keyUsed = "KEY_USED"
        case vaultKeyChange = "VAULT_KEY_CHANGE"
    }
}

extension UserDeviceAPIClient.Accountrecovery.Deactivate {
    public typealias Response = Empty?
}
