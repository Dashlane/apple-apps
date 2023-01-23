import Foundation
extension UserDeviceAPIClient.Devices {
        public struct DeactivateDevice {
        public static let endpoint: Endpoint = "/devices/DeactivateDevice"

        public let api: UserDeviceAPIClient

                public func callAsFunction(deviceId: String, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(deviceId: deviceId)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var deactivateDevice: DeactivateDevice {
        DeactivateDevice(api: api)
    }
}

extension UserDeviceAPIClient.Devices.DeactivateDevice {
        struct Body: Encodable {

                public let deviceId: String
    }
}

extension UserDeviceAPIClient.Devices.DeactivateDevice {
    public typealias Response = Empty?
}
