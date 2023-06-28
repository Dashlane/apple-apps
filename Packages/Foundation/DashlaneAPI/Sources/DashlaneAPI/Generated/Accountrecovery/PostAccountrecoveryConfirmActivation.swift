import Foundation
extension UserDeviceAPIClient.Accountrecovery {
        public struct ConfirmActivation: APIRequest {
        public static let endpoint: Endpoint = "/accountrecovery/ConfirmActivation"

        public let api: UserDeviceAPIClient

                @discardableResult
        public func callAsFunction(recoveryId: String, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(recoveryId: recoveryId)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var confirmActivation: ConfirmActivation {
        ConfirmActivation(api: api)
    }
}

extension UserDeviceAPIClient.Accountrecovery.ConfirmActivation {
        public struct Body: Encodable {

        private enum CodingKeys: String, CodingKey {
            case recoveryId = "recoveryId"
        }

                public let recoveryId: String
    }
}

extension UserDeviceAPIClient.Accountrecovery.ConfirmActivation {
    public typealias Response = Empty?
}
