import Foundation

public enum DeviceListEntry: Hashable {
    case independentDevice(BucketDevice)
    case group(BucketPairingGroup, main: BucketDevice, devices: Set<BucketDevice>)
}


extension DeviceListEntry {
    public var displayedDevice: BucketDevice {
        switch self {
            case let .independentDevice(device):
                return device
            case let .group(_, device, _):
                return device
        }
    }
}

extension Collection where Element == DeviceListEntry {
                        public func monobucketOwner() -> BucketDevice? {
        guard let ownerGroup = monobucketPairingGroupOwner() else {
            return first { item in
                switch item {
                    case let .independentDevice(device):
                        return device.isBucketOwner
                    case .group:
                        return false
                }
            }?.displayedDevice
        }

        return ownerGroup
    }

    private func monobucketPairingGroupOwner() -> BucketDevice? {
        return first { item in
            switch item {
                case .independentDevice:
                    return false
                case let .group(group, _, _):
                    return group.isBucketOwner
            }
        }?.displayedDevice
    }

    public func filterByDevice(_ isIncluded: (BucketDevice) -> Bool) -> [DeviceListEntry] {
        return filter { item in
            switch item {
                case let .independentDevice(device):
                    return isIncluded(device)
                case let .group(_, _, devices):
                    return devices.allSatisfy(isIncluded)
            }
        }
    }
}
