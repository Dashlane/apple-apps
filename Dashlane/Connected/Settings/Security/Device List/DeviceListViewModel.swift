import Combine
import CoreNetworking
import CoreSession
import CoreTypes
import DashlaneAPI
import Foundation
import LoginKit

@MainActor
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

  private let userDeviceAPIClient: UserDeviceAPIClient
  private let reachability: NetworkReachabilityProtocol
  private var subscription: AnyCancellable?
  private var logoutAndDeleteHandler: (() -> Void)?

  init(
    userDeviceAPIClient: UserDeviceAPIClient,
    session: Session, reachability: NetworkReachabilityProtocol,
    logoutHandler: SessionLifeCycleHandler?
  ) {
    self.currentDeviceId = session.configuration.keys.serverAuthentication.deviceId
    self.reachability = reachability
    self.userDeviceAPIClient = userDeviceAPIClient
    self.logoutAndDeleteHandler = { [weak logoutHandler] in
      logoutHandler?.logoutAndPerform(action: .deleteLocalData(for: session))
    }
    fetch()
  }

  init(
    userDeviceAPIClient: UserDeviceAPIClient,
    currentDeviceId: String,
    reachability: NetworkReachabilityProtocol
  ) {
    self.userDeviceAPIClient = userDeviceAPIClient
    self.currentDeviceId = currentDeviceId
    self.reachability = reachability
    listStatus = .loaded
    fetch()
  }

  func fetch() {
    listStatus = .loading
    Task {
      do {
        let list = try await userDeviceAPIClient.devices.listDevices()
        self.devices = list.devices.sorted(by: { $0.lastActivityDateUnix > $1.lastActivityDateUnix }
        ).map({ $0.makeBucketDevice() })
      } catch {
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

    subscription = reachability.isConnectedPublisher
      .receive(on: DispatchQueue.main)
      .filter { $0 }.sink { [weak self] _ in
        self?.fetch()
      }
  }

  private func update(with devices: [BucketDevice]) {
    let displayDateFormatter = RelativeDateTimeFormatter()
    displayDateFormatter.dateTimeStyle = .named

    let devicesAndDate: [DevicesAndDateGroup] = Dictionary(
      grouping: devices,
      by: { device in
        if device.id == currentDeviceId {
          return .last24Hours
        } else {
          return DateGroup(date: device.lastActivityDate)
        }
      }
    ).mapValues { devices in
      devices.sorted { device1, device2 in
        guard device1.id != currentDeviceId else {
          return true
        }
        return device1.lastUpdateDate > device2.lastActivityDate
      }
    }.map({ DevicesAndDateGroup(dateGroup: $0.key, devices: $0.value) })
    listStatus = .loaded
    self.devicesGroups = devicesAndDate.sorted(by: { $0.dateGroup < $1.dateGroup })
  }

  func rename(_ device: BucketDevice, with name: String) async {
    try? await userDeviceAPIClient.devices.renameDevice(accessKey: device.id, updatedName: name)
    self.fetch()
  }

  func deactivate(_ devices: [BucketDevice]) async {
    let devicesToUnlink = Set(devices.map({ DeviceListEntry.independentDevice($0) }))
    do {
      try await userDeviceAPIClient.unlink(devicesToUnlink)
      if devices.contains(where: { $0.id == self.currentDeviceId }) {
        self.logoutAndDeleteHandler?()
      } else {
        self.fetch()
      }
    } catch {
      self.isDeactivationFailed = true
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
    return DeviceListViewModel(
      userDeviceAPIClient: UserDeviceAPIClient.fake,
      session: .mock,
      reachability: .mock(),
      logoutHandler: nil)
  }

}

extension BucketDevice {
  fileprivate static var iPhone: BucketDevice {
    .init(
      id: "0000",
      name: "My iPhone",
      platform: .iphone,
      creationDate: .distantPast,
      lastUpdateDate: .now,
      lastActivityDate: .now,
      isBucketOwner: false,
      isTemporary: false)
  }
}

extension [BucketDevice] {

  fileprivate func keeping(ids: Set<String>) -> [BucketDevice] {
    return filter({ device in
      ids.contains(where: { $0 == device.id })
    })
  }
}
