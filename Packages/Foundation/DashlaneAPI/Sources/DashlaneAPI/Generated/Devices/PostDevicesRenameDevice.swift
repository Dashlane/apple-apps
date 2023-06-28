import Foundation
extension UserDeviceAPIClient.Devices {
        public struct RenameDevice: APIRequest {
        public static let endpoint: Endpoint = "/devices/RenameDevice"

        public let api: UserDeviceAPIClient

                @discardableResult
        public func callAsFunction(accessKey: String, updatedName: String, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(accessKey: accessKey, updatedName: updatedName)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var renameDevice: RenameDevice {
        RenameDevice(api: api)
    }
}

extension UserDeviceAPIClient.Devices.RenameDevice {
        public struct Body: Encodable {

        private enum CodingKeys: String, CodingKey {
            case accessKey = "accessKey"
            case updatedName = "updatedName"
        }

                public let accessKey: String

                public let updatedName: String
    }
}

extension UserDeviceAPIClient.Devices.RenameDevice {
    public typealias Response = Empty?
}
