import Foundation
extension UserDeviceAPIClient.Devices {
        public struct UpdateDeviceInfo: APIRequest {
        public static let endpoint: Endpoint = "/devices/UpdateDeviceInfo"

        public let api: UserDeviceAPIClient

                public func callAsFunction(deviceInformation: String, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(deviceInformation: deviceInformation)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var updateDeviceInfo: UpdateDeviceInfo {
        UpdateDeviceInfo(api: api)
    }
}

extension UserDeviceAPIClient.Devices.UpdateDeviceInfo {
        public struct Body: Encodable {

        private enum CodingKeys: String, CodingKey {
            case deviceInformation = "deviceInformation"
        }

        public let deviceInformation: String
    }
}

extension UserDeviceAPIClient.Devices.UpdateDeviceInfo {
    public typealias Response = Empty?
}
