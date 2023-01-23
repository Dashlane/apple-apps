import Foundation
import DashTypes
import Combine

public class DeviceUnlinker {
    public enum UnlinkMode: Equatable {
                case monobucket
                case multiple(Int)
    }
    public typealias  LimitCompletion = (Result<Int?, Error>) -> Void
    private(set) public var currentUserDevices: Set<DeviceListEntry> = []
    private(set) public var accountDeviceLimit: Int? = nil
    public let login: Login
    private let deviceService: DeviceServiceProtocol
    private let currentDeviceId: String
    private let limitProvider: (@escaping LimitCompletion) -> Void
    public var mode: UnlinkMode? {
        guard let limit = accountDeviceLimit, limit <= currentUserDevices.count, limit > 0 else {
            return nil
        }

        switch limit {
            case 1:
                return .monobucket
            default:
                return .multiple(limit)
        }
    }

    init(session: RemoteLoginSession,
         remoteLoginDelegate: RemoteLoginDelegate) {
        self.login = session.login
        self.limitProvider = { (completion: @escaping LimitCompletion) in
            remoteLoginDelegate.deviceLimit(for: session.login, authentication: session.authentication, completion: completion)
        }
        self.currentDeviceId = session.authentication.deviceId
        self.deviceService = remoteLoginDelegate.deviceService(for: login, authentication: session.authentication)
    }

    public init(login: Login,
                currentDeviceId: String,
                deviceService: DeviceServiceProtocol,
                limitProvider: @escaping (LimitCompletion) -> Void) {
        self.login = login
        self.limitProvider = limitProvider
        self.currentDeviceId = currentDeviceId
        self.deviceService = deviceService
    }

    public func unlink(_ devices: Set<DeviceListEntry>, completion: @escaping (Result<Void, Error>) -> Void) {
        guard !devices.isEmpty else {
            completion(.success)
            return
        }
        deviceService.unlink(devices, completion: completion)
    }

    public func refreshLimitAndDevices(_ completion: @escaping (Result<Void, Error>) -> Void) {
        limitProvider { result in
            switch result {
                case let .success(limit):
                    self.accountDeviceLimit = limit
                    self.refreshDevices(completion)
                case let .failure(error):
                    completion(.failure(error))
            }
        }
    }

    private func refreshDevices(_ completion: @escaping (Result<Void, Error>) -> Void) {
        deviceService.list { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
                case let .success(response):
                    let devices = response
                        .groupedByPairingGroup()
                        .filterByDevice {
                            $0.id != self.currentDeviceId 
                        }
                    self.currentUserDevices = Set(devices)
                    completion(.success)
                case let .failure(error):
                    completion(.failure(error))
            }

        }
    }
}


import Combine

extension DeviceUnlinker {
    @available(OSX 10.15, *)
    public func refreshLimitAndDevices() -> Future<Void, Error> {
        Future {
            self.refreshLimitAndDevices($0)
        }
    }
}
