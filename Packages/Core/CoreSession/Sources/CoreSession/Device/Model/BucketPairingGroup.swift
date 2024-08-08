import DashlaneAPI
import Foundation

public struct BucketPairingGroup: Decodable, Hashable, Sendable {
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

extension Collection where Element == BucketDevice {
  public func filter(
    in group: UserDeviceAPIClient.Devices.ListDevices.Response.PairingGroupsElement
  ) -> [BucketDevice] {
    return group.devices.compactMap { deviceID in
      self.first(where: { $0.id == deviceID })
    }
  }
}

extension UserDeviceAPIClient.Devices.ListDevices.Response.PairingGroupsElement {
  func makeBucketPairingGroup() -> BucketPairingGroup {
    BucketPairingGroup(
      pairingGroupUUID: pairingGroupUUID,
      devicesIDs: devices,
      isBucketOwner: isBucketOwner ?? false)
  }
}
