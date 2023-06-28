import Foundation
extension UserDeviceAPIClient.Devices {
        public struct DeactivateDevices: APIRequest {
        public static let endpoint: Endpoint = "/devices/DeactivateDevices"

        public let api: UserDeviceAPIClient

                @discardableResult
        public func callAsFunction(deviceIds: [String]? = nil, pairingGroupIds: [String]? = nil, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(deviceIds: deviceIds, pairingGroupIds: pairingGroupIds)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var deactivateDevices: DeactivateDevices {
        DeactivateDevices(api: api)
    }
}

extension UserDeviceAPIClient.Devices.DeactivateDevices {
        public struct Body: Encodable {

        private enum CodingKeys: String, CodingKey {
            case deviceIds = "deviceIds"
            case pairingGroupIds = "pairingGroupIds"
        }

                public let deviceIds: [String]?

                public let pairingGroupIds: [String]?
    }
}

extension UserDeviceAPIClient.Devices.DeactivateDevices {
    public typealias Response = Empty?
}
