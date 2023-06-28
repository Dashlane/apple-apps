import Foundation

public struct ListDevicesResponse: Decodable {
    public let pairingGroups: Set<BucketPairingGroup>
    public let devices: Set<BucketDevice>

    public init(pairingGroups: Set<BucketPairingGroup> = [], devices: Set<BucketDevice> = []) {
        self.pairingGroups = pairingGroups
        self.devices = devices
    }
}

extension ListDevicesResponse {
        public func groupedByPairingGroup() -> Set<DeviceListEntry> {
        var devices = self.devices.filter { !$0.isTemporary }
        var groups: [DeviceListEntry] = []
        for group in pairingGroups {
            let devicesInGroup = devices.filter(in: group)
            guard !devicesInGroup.isEmpty,
                  let lastActive = devicesInGroup.lastActive() else {
                continue
            }
            groups.append(.group(group, main: lastActive, devices: Set(devicesInGroup)))
            devices.subtract(devicesInGroup)
        }

        return Set(devices.map { .independentDevice($0) } + groups )
    }
}
