import CoreLocalization
import CoreSession
import Foundation

extension DevicePlatform {
  var imageAsset: ImageAsset {
    switch self {
    case .iphone, .ipad, .ipod, .macos, .catalyst:
      return Asset.applePlatform
    case .windows:
      return Asset.windowsPlatform
    case .android:
      return Asset.androidPlatform
    case .web:
      return Asset.webPlatform
    }
  }
}

extension BucketDevice {
  var displayedDate: String {
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .full
    let timeAgo = formatter.localizedString(for: lastActivityDate, relativeTo: Date())
    return L10n.Core.deviceUnlinkingUnlinkLastActive(timeAgo)
  }
}

extension DeviceListEntry: Identifiable {
  public var id: String {
    displayedDevice.id
  }
}
