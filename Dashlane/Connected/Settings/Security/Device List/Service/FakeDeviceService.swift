import Foundation
import CoreSession

struct FakeDeviceService: DeviceServiceProtocol {
    var requestPairingGroupResult: Result<Void, Error>
    var listResult: Result<ListDevicesResponse, Error>
    var unlinkResult: Result<Void, Error>

    init(requestPairingGroupResult: Result<Void, Error> = .success,
         listResult: Result<ListDevicesResponse, Error> = .success(ListDevicesResponse()),
         unlinkResult: Result<Void, Error> = .success) {
        self.requestPairingGroupResult = requestPairingGroupResult
        self.listResult = listResult
        self.unlinkResult = unlinkResult
    }

    func requestPairingGroup(completion: @escaping (Result<Void, Error>) -> Void) {
        completion(requestPairingGroupResult)
    }

    func list(completion: @escaping (Result<ListDevicesResponse, Error>) -> Void) {
        completion(listResult)
    }

    func unlink(_ devices: Set<DeviceListEntry>, completion: @escaping (Result<Void, Error>) -> Void) {
        completion(unlinkResult)
    }

    func rename(_ device: BucketDevice, with name: String, completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success)
    }
}
