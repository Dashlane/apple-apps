import CoreLocalization
import CoreSession
import DesignSystem
import Foundation
import SwiftUI

extension Image {
  init(platform: DevicePlatform) {
    switch platform {
    case .iphone, .ipad, .ipod, .macos, .catalyst:
      self = .ds.os.apple.filled
    case .windows:
      self = .ds.os.windows.filled
    case .android:
      self = .ds.os.android.filled
    case .web:
      self = .ds.web.filled
    }
  }
}

extension BucketDevice {
  var displayedDate: String {
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .full
    let timeAgo = formatter.localizedString(for: lastActivityDate, relativeTo: Date())
    return CoreL10n.deviceUnlinkingUnlinkLastActive(timeAgo)
  }
}

extension DeviceListEntry: Identifiable {
  public var id: String {
    displayedDevice.id
  }
}
