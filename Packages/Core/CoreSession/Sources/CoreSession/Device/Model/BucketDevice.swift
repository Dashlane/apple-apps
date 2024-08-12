import DashlaneAPI
import Foundation

public struct BucketDevice: Hashable, Sendable {
  public let id: String
  public let name: String
  public let platform: DevicePlatform
  public let creationDate: Date
  public let lastUpdateDate: Date
  public let lastActivityDate: Date
  public let isBucketOwner: Bool
  public let isTemporary: Bool

  public init(
    id: String,
    name: String,
    platform: DevicePlatform,
    creationDate: Date,
    lastUpdateDate: Date,
    lastActivityDate: Date,
    isBucketOwner: Bool,
    isTemporary: Bool
  ) {
    self.id = id
    self.name = name
    self.platform = platform
    self.creationDate = creationDate
    self.lastUpdateDate = lastUpdateDate
    self.lastActivityDate = lastActivityDate
    self.isBucketOwner = isBucketOwner
    self.isTemporary = isTemporary
  }

}

extension Collection where Element == BucketDevice {
  public func sortedByUpdateDate() -> [Element] {
    return self.sorted { $0.lastUpdateDate > $1.lastUpdateDate }
  }

  public func lastActive() -> Element? {
    let devices = self.sortedByUpdateDate()

    if let desktop = devices.first(where: { $0.platform.isDesktop }) {
      return desktop
    }

    if let `extension` = devices.first(where: { $0.platform == .web }) {
      return `extension`
    }

    return nil
  }
}

public enum DevicePlatform: String, Decodable, Sendable {
  case iphone = "server_iphone"
  case ipad = "server_ipad"
  case ipod = "server_ipod"
  case android = "server_android"
  case macos = "server_macosx"
  case catalyst = "server_catalyst"
  case windows = "server_win"
  case web

  var isDesktop: Bool {
    return self == .macos || self == .windows
  }
}

extension UserDeviceAPIClient.Devices.ListDevices.Response.DevicesElement {

  var platform: DevicePlatform {
    guard let devicePlatform else {
      return .web
    }
    return .init(rawValue: devicePlatform) ?? .web
  }

  public func makeBucketDevice() -> BucketDevice {
    BucketDevice(
      id: deviceId,
      name: deviceName ?? "",
      platform: platform,
      creationDate: Date(timeIntervalSince1970: TimeInterval(creationDateUnix)),
      lastUpdateDate: Date(timeIntervalSince1970: TimeInterval(lastUpdateDateUnix)),
      lastActivityDate: Date(timeIntervalSince1970: TimeInterval(lastActivityDateUnix)),
      isBucketOwner: isBucketOwner ?? false,
      isTemporary: temporary)
  }

  public init(
    id: String,
    name: String,
    platform: DevicePlatform,
    creationDate: Date,
    lastUpdateDate: Date,
    lastActivityDate: Date,
    isBucketOwner: Bool,
    isTemporary: Bool
  ) {
    self.init(
      deviceId: id,
      deviceName: name,
      devicePlatform: platform.rawValue,
      creationDateUnix: Int(creationDate.timeIntervalSince1970),
      lastUpdateDateUnix: Int(lastUpdateDate.timeIntervalSince1970),
      lastActivityDateUnix: Int(lastActivityDate.timeIntervalSince1970),
      temporary: isTemporary,
      isBucketOwner: isBucketOwner)
  }
}
