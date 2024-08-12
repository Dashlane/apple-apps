import DashTypes
import DashlaneAPI
import Foundation

extension UserDeviceAPIClient {

  public func unlink(_ devices: Set<DeviceListEntry>) async throws {
    var deviceIds: Set<String> = []
    var pairingGroupIds: Set<String> = []

    for deviceEntry in devices {
      switch deviceEntry {
      case let .independentDevice(device):
        deviceIds.insert(device.id)
      case let .group(group, _, _):
        pairingGroupIds.insert(group.pairingGroupUUID)
      }
    }
    try await self.devices.deactivateDevices(
      .init(deviceIds: Array(deviceIds), pairingGroupIds: Array(pairingGroupIds)))
  }
}
