import Foundation
extension UserDeviceAPIClient.Sync {
        public struct ConfirmMasterPasswordChangeDone: APIRequest {
        public static let endpoint: Endpoint = "/sync/ConfirmMasterPasswordChangeDone"

        public let api: UserDeviceAPIClient

                @discardableResult
        public func callAsFunction(timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body()
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var confirmMasterPasswordChangeDone: ConfirmMasterPasswordChangeDone {
        ConfirmMasterPasswordChangeDone(api: api)
    }
}

extension UserDeviceAPIClient.Sync.ConfirmMasterPasswordChangeDone {
        public struct Body: Encodable {
    }
}

extension UserDeviceAPIClient.Sync.ConfirmMasterPasswordChangeDone {
    public typealias Response = Empty?
}
