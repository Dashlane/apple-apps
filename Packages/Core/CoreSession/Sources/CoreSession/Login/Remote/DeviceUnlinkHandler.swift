import Combine
import DashTypes
import DashlaneAPI
import Foundation

public class DeviceUnlinker {
  public enum UnlinkMode: Equatable {
    case monobucket
    case multiple(Int)
  }
  public typealias LimitCompletion = (Result<Int?, Error>) -> Void
  private(set) public var currentUserDevices: Set<DeviceListEntry> = []
  private(set) public var accountDeviceLimit: Int?
  public let login: Login
  private let userDeviceAPIClient: UserDeviceAPIClient
  private let currentDeviceId: String
  private let limitProvider: () async throws -> Int?
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

  init(session: RemoteLoginSession, userDeviceAPIClient: UserDeviceAPIClient) {
    self.login = session.login
    self.limitProvider = {
      let status = try await userDeviceAPIClient.premium.getPremiumStatus()

      let limitCapability = status.capabilities.first {
        $0.capability == .devicesLimit
      }

      let syncCapability = status.capabilities.first {
        $0.capability == .sync
      }

      if let limitCapability, limitCapability.enabled == true,
        let limit = limitCapability.info?.limit
      {
        return limit
      } else if let syncCapability, syncCapability.enabled == false {
        return 1
      } else {
        return nil
      }
    }

    self.currentDeviceId = session.authentication.deviceId
    self.userDeviceAPIClient = userDeviceAPIClient
  }

  public init(
    login: Login,
    currentDeviceId: String,
    userDeviceAPIClient: UserDeviceAPIClient,
    limitProvider: @escaping () async throws -> Int?
  ) {
    self.login = login
    self.limitProvider = limitProvider
    self.currentDeviceId = currentDeviceId
    self.userDeviceAPIClient = userDeviceAPIClient
  }

  public func unlink(_ devices: Set<DeviceListEntry>) async throws {
    guard !devices.isEmpty else {
      return
    }
    try await userDeviceAPIClient.unlink(devices)
  }

  public func refreshLimitAndDevices() async throws {
    self.accountDeviceLimit = try await limitProvider()
    try await self.refreshDevices()
  }

  private func refreshDevices() async throws {
    let devicesList = try await userDeviceAPIClient.devices.listDevices()
    let devices =
      devicesList
      .groupedByPairingGroup()
      .filterByDevice {
        $0.id != self.currentDeviceId
      }
    self.currentUserDevices = Set(devices)
  }
}
extension DeviceUnlinker {
  @available(OSX 10.15, *)
  public func refreshLimitAndDevices() -> Future<Void, Error> {
    Future { completion in
      Task {
        do {
          try await self.refreshLimitAndDevices()
          completion(.success)
        } catch {
          completion(.failure(error))
        }
      }
    }
  }
}
