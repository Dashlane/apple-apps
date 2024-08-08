import Foundation
import SwiftTreats

struct BrazeAnnouncementExtraKeys {

  enum Device: String {
    case iPhone = "APPLE_PHONE"
    case iPad = "APPLE_IPAD"
    case mac = "APPLE_MAC"
  }

  enum AnnouncementType: String {
    case modal = "MODAL"
    case notificationCenter = "NOTIFICATION_CENTER"
  }

  enum Key: String {
    case excludedDevices = "DEVICE_EXCLUDE"
    case announcementType = "ANNOUNCEMENT_TYPE"
  }

  let excludedDevices: [Device]
  let announcementType: AnnouncementType

  init(extras: [String: String]) {

    if let rawDevices = extras[Key.excludedDevices.rawValue] {
      excludedDevices = rawDevices.components(separatedBy: ",")
        .compactMap({ Device(rawValue: $0) })
    } else {
      excludedDevices = []
    }

    if let rawAnnouncementType = extras[Key.announcementType.rawValue],
      let announcementType = AnnouncementType(rawValue: rawAnnouncementType)
    {
      self.announcementType = announcementType
    } else {
      announcementType = .modal
    }
  }
}

extension [BrazeAnnouncementExtraKeys.Device] {

  func shouldExcludeCurrentDevice() -> Bool {
    if Device.isMac {
      return self.contains(.mac)
    } else if Device.isIpad {
      return self.contains(.iPad)
    } else {
      return self.contains(.iPhone)
    }
  }
}
