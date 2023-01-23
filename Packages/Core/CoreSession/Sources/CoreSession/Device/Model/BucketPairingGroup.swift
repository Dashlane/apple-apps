import Foundation

public struct BucketPairingGroup: Decodable, Hashable {
        public let pairingGroupUUID: String
        public let devices: [String]
        public let isBucketOwner: Bool

    public init(pairingGroupUUID: String, devicesIDs: [String], isBucketOwner: Bool = false) {
        self.pairingGroupUUID = pairingGroupUUID
        self.devices = devicesIDs
        self.isBucketOwner = isBucketOwner
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(pairingGroupUUID)
    }
}

public extension Collection where Element == BucketDevice {
    func filter(in group: BucketPairingGroup) -> [BucketDevice] {
        return group.devices.compactMap { deviceID in
            self.first(where: { $0.id == deviceID })
        }
    }
}
