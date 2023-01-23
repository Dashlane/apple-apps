import Foundation
extension UserDeviceAPIClient.Account {
        public struct SetAccountRecovery {
        public static let endpoint: Endpoint = "/account/SetAccountRecovery"

        public let api: UserDeviceAPIClient

                @discardableResult
        public func callAsFunction(vaultKey: String, deviceName: String? = nil, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(vaultKey: vaultKey, deviceName: deviceName)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var setAccountRecovery: SetAccountRecovery {
        SetAccountRecovery(api: api)
    }
}

extension UserDeviceAPIClient.Account.SetAccountRecovery {
        struct Body: Encodable {

                public let vaultKey: String

                public let deviceName: String?
    }
}

extension UserDeviceAPIClient.Account.SetAccountRecovery {
    public typealias Response = Empty?
}
