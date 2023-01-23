import Foundation
import DashTypes
import CoreSession
import Combine
import CoreNetworking
import LoginKit

class DeviceListViewModel: ObservableObject, SessionServicesInjecting {
    enum ListStatus {
        case loading
        case loaded
        case error
        case noInternet
    }

    struct DevicesAndDateGroup: Identifiable, Equatable, Hashable {
        let dateGroup: DateGroup
        let devices: [BucketDevice]

        var id: Int { dateGroup.id }
    }

    @Published
    var devicesGroups: [DevicesAndDateGroup] = []

    private var devices: [BucketDevice] = [] {
        didSet {
            self.update(with: devices)
        }
    }

    @Published
    var listStatus: ListStatus = .loading

    @Published
    var isDeactivationFailed: Bool = false

    let currentDeviceId: String

    private let deviceService: DeviceServiceProtocol
    private let reachability: NetworkReachability
    private var subcription: AnyCancellable?
    private var logoutAndDeleteHandler: (() -> Void)?

    init(apiClient: DeprecatedCustomAPIClient, legacyWebService: LegacyWebService, session: Session, reachability: NetworkReachability, logoutHandler: SessionLifeCycleHandler?) {
        deviceService = DeviceService(apiClient: apiClient)

        self.currentDeviceId = session.configuration.keys.serverAuthentication.deviceId
        self.reachability = reachability
        self.logoutAndDeleteHandler = { [weak logoutHandler] in
            logoutHandler?.logoutAndPerform(action: .deleteLocalData(for: session))
        }
        fetch()
    }

    init(deviceService: DeviceServiceProtocol,
         currentDeviceId: String,
         reachability: NetworkReachability) {
        self.deviceService = deviceService
        self.currentDeviceId = currentDeviceId
        self.reachability = reachability
        listStatus = .loaded
        fetch()
    }

    func fetch() {
        listStatus = .loading
        deviceService
            .list { [weak self] result in
                guard let self = self else {
                    return
                }

                switch result {
                case let .success(response):
                    self.devices = response.devices.sorted(by: { $0.lastActivityDate > $1.lastActivityDate })
                case .failure:
                    self.listStatus = self.reachability.isConnected ? .error : .noInternet
                    self.devicesGroups = []
                    self.fetchWhenInternetConnectionRestores()
                }
            }
    }

    private func fetchWhenInternetConnectionRestores() {
        guard !self.reachability.isConnected else {
            return
        }

        subcription = reachability.$isConnected
            .receive(on: DispatchQueue.main)
            .filter { $0 }.sink { [weak self] _ in
            self?.fetch()
        }
    }

    private func update(with devices: [BucketDevice]) {
        let displayDateFormatter = RelativeDateTimeFormatter()
        displayDateFormatter.dateTimeStyle = .named

        let devicesAndDate: [DevicesAndDateGroup] = Dictionary(grouping: devices, by: { device in
            if device.id == currentDeviceId { 
                return .last24Hours
            } else {
                return DateGroup(date: device.lastActivityDate)
            }
        })  .mapValues { devices in
            devices.sorted { device1, device2 in
                guard device1.id != currentDeviceId else { 
                    return true
                }
                return device1.lastUpdateDate > device2.lastActivityDate
            }
        }.map({ DevicesAndDateGroup(dateGroup: $0.key, devices: $0.value)})
        listStatus = .loaded
        self.devicesGroups = devicesAndDate.sorted(by: { $0.dateGroup < $1.dateGroup })
    }

    func rename(_ device: BucketDevice, with name: String) {
        deviceService.rename(device, with: name) { [weak self] _ in
            self?.fetch()
        }
    }

    func deactivate(_ devices: [BucketDevice]) {
        let devicesToUnlink = Set(devices.map({ DeviceListEntry.independentDevice($0) }))
        deviceService
            .unlink(devicesToUnlink) { [weak self] result in
                guard let self = self else {
                    return
                }

                switch result {
                    case .success:
                        if devices.contains(where: { $0.id == self.currentDeviceId}) {
                            self.logoutAndDeleteHandler?()
                        } else {
                            self.fetch()
                        }
                    case .failure:
                        self.isDeactivationFailed = true

                }
            }
    }

    func allDevicesButCurrentOne() -> [BucketDevice] {
        devices.filter({ $0.id != currentDeviceId })
    }

    func allDevicesIds() -> Set<String> {
        Set(devices.map({ $0.id }))
    }

    func allDevicesIdsButCurrentOne() -> Set<String> {
        allDevicesIds().filter({ $0 != currentDeviceId })
    }

    func devices(forIds ids: Set<String>) -> [BucketDevice] {
        return devices.keeping(ids: ids)
    }

    static var mock: DeviceListViewModel {
        DeviceListViewModel(apiClient: .fake,
                            legacyWebService: LegacyWebServiceMock(response: ""),
                            session: .mock,
                            reachability: NetworkReachability(),
                            logoutHandler: nil)
    }

}

private extension [BucketDevice] {

    func keeping(ids: Set<String>) -> [BucketDevice] {
        return filter({ device in
            ids.contains(where: { $0 == device.id })
        })
    }
}
