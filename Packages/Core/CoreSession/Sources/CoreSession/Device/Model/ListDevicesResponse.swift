import DashlaneAPI
import Foundation

public typealias ListDevicesResponse = UserDeviceAPIClient.Devices.ListDevices.Response

extension UserDeviceAPIClient.Devices.ListDevices.Response {
  public func groupedByPairingGroup() -> Set<DeviceListEntry> {
    var devices = Set(self.devices.filter { !$0.temporary }.map({ $0.makeBucketDevice() }))
    var groups: [DeviceListEntry] = []
    for group in pairingGroups {
      let devicesInGroup = devices.filter(in: group)
      guard !devicesInGroup.isEmpty,
        let lastActive = devicesInGroup.lastActive()
      else {
        continue
      }
      groups.append(
        .group(group.makeBucketPairingGroup(), main: lastActive, devices: Set(devicesInGroup)))
      devices.subtract(devicesInGroup)
    }

    return Set(devices.map { .independentDevice($0) } + groups)
  }
}
