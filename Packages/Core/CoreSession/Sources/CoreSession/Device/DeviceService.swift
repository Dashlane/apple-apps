import Foundation
import DashTypes

public protocol DeviceServiceProtocol {
    func requestPairingGroup(completion: @escaping (Result<Void, Error>) -> Void)
    func list(completion: @escaping (Result<ListDevicesResponse, Error>) -> Void)
    func unlink(_ devices: Set<DeviceListEntry>,
                completion: @escaping (Result<Void, Error>) -> Void)
    func rename(_ device: BucketDevice,
                with name: String,
                completion: @escaping (Result<Void, Error>) -> Void)
}

public class DeviceService: DeviceServiceProtocol {
    let apiClient: DeprecatedCustomAPIClient

    public init(apiClient: DeprecatedCustomAPIClient) {
        self.apiClient = apiClient
    }

        public func requestPairingGroup(completion: @escaping (Result<Void, Error>) -> Void) {

        struct Empty: Codable {}

        apiClient.sendRequest(to: "/v1/pairing/RequestPairing",
                              using: .post,
                              input: Empty()) { (result: Result<Empty, Error>) in
            completion(result.map { _ in })
        }
    }

        public func list(completion: @escaping (Result<ListDevicesResponse, Error>) -> Void) {

        struct Empty: Encodable {}

        apiClient.sendRequest(to: "/v1/devices/ListDevices",
                              using: .post,
                              input: Empty()) { (result: Result<ListDevicesResponse, Error>) in
            completion(result)
        }
    }

        public func unlink(_ devices: Set<DeviceListEntry>,
                       completion: @escaping (Result<Void, Error>) -> Void) {

        struct Body: Encodable {
            var deviceIds: Set<String> = []
            var pairingGroupIds: Set<String> = []
        }
        struct Empty: Decodable {}

        var body = Body()

        for deviceEntry in devices {
            switch deviceEntry {
            case let .independentDevice(device):
                body.deviceIds.insert(device.id)
            case let .group(group, _, _):
                body.pairingGroupIds.insert(group.pairingGroupUUID)
            }
        }

        apiClient.sendRequest(to: "/v1/devices/DeactivateDevices",
                              using: .post,
                              input: body) { (result: Result<Empty, Error>) in
            completion(result.map { _ in })
        }
    }
        public func rename(_ device: BucketDevice,
                       with name: String,
                       completion: @escaping (Result<Void, Error>) -> Void) {

        struct Body: Encodable {
            var accessKey: String
            var updatedName: String
        }
        struct Empty: Decodable {}

        let body = Body(accessKey: device.id, updatedName: name)

        apiClient.sendRequest(to: "/v1/devices/RenameDevice",
                              using: .post,
                              input: body) { (result: Result<Empty, Error>) in
            completion(result.map { _ in })
        }
    }

}
