import Foundation
import SwiftTreats

enum UnsupportedDevice: String, CaseIterable {
  case iPhone6s = "iPhone8,1"
  case iPhone6sPlus = "iPhone8,2"
  case iPhoneSE = "iPhone8,4"
  case iPhone7 = "iPhone9,1"
  case iPhone7Plus = "iPhone9,2"
  case iPhone7Bis = "iPhone9,3"
  case iPhone7PlusBis = "iPhone9,4"
  case iPadMini4 = "iPad5,1"
  case iPod7th = "iPod9,1"
  case macBookPro13InchEarly2015 = "MacBookPro12,1"
  case macBookPro15Inch2015 = "MacBookPro11,4"
  case macBookPro15Inch2015Bis = "MacBookPro11,5"
  case macBookPro13Inch2016 = "MacBookPro13,1"
  case macBookPro13Inch2016Bis = "MacBookPro13,2"
  case macBookPro15Inch2016 = "MacBookPro13,3"
  case macBookAir13Inch2015And2017 = "MacBookAir7,2"
  case macBookAir11Inch2015 = "MacBookAir7,1"
  case macBook12Inch2016 = "MacBook9,1"
  case macMini2014 = "Macmini7,1"
  case iMac5K2015 = "iMac17,1"
  case iMac4K2015 = "iMac16,2"
  case iMac2015 = "iMac16,1"
}

public class UpdateOperatingSystemAnnouncement: HomeModalAnnouncement,
  HomeAnnouncementsServicesInjecting
{

  let triggers: Set<HomeModalAnnouncementTrigger> = [.sessionUnlocked]

  let informationProvider: DeviceInformationProvider
  let cache: UpdateOperatingSystemCacheProtocol

  public init(
    informationProvider: DeviceInformationProvider = DeviceInformation(),
    cache: UpdateOperatingSystemCacheProtocol = UpdateOperatingSystemCache()
  ) {
    self.informationProvider = informationProvider
    self.cache = cache
  }

  func shouldDisplay() -> Bool {
    guard informationProvider.systemWillBeDropped else {
      cache.cleanup()
      return false
    }

    guard cache.canDisplayAnnouncement() else {
      return false
    }

    guard UnsupportedDevice(rawValue: informationProvider.modelName) == nil else {
      return false
    }

    return true
  }

  var announcement: HomeModalAnnouncementType? {
    guard shouldDisplay() else { return nil }
    return .alert(.upgradeOperatingSystem)
  }
}

public protocol DeviceInformationProvider {
  var modelName: String { get }
  var systemWillBeDropped: Bool { get }
}

public struct DeviceInformation: DeviceInformationProvider {
  public let modelName: String
  public let systemWillBeDropped: Bool

  public init() {
    modelName = Device.hardwareName
    if #unavailable(iOS 16) {
      self.systemWillBeDropped = true
    } else {
      self.systemWillBeDropped = false
    }
  }
}

private struct DeviceInformationProviderMock: DeviceInformationProvider {
  var modelName: String
  var systemWillBeDropped: Bool
}

public protocol UpdateOperatingSystemCacheProtocol: AnyObject {
  func canDisplayAnnouncement() -> Bool
  func dismiss()
  func cleanup()
}

extension UpdateOperatingSystemCacheProtocol where Self == UpdateOperatingSystemCacheMock {
  static var mock: UpdateOperatingSystemCacheProtocol {
    UpdateOperatingSystemCacheMock(canDisplay: true)
  }
}

public class UpdateOperatingSystemCache: UpdateOperatingSystemCacheProtocol {

  @SharedUserDefault(key: dismissedAnnouncementKey, userDefaults: .standard)
  public var lastDismissalDate: Date?
  private static let dismissedAnnouncementKey = "UPDATE_OPERATING_SYSTEM_IOS_15_ALERT_DISMISSED"

  public func canDisplayAnnouncement() -> Bool {
    guard let lastDismissalDate else {
      return true
    }
    guard
      let oneMonthAfterLastDismissal = Calendar.current.date(
        byAdding: .month, value: 1, to: lastDismissalDate)
    else {
      return false
    }
    return oneMonthAfterLastDismissal < Date()
  }

  public func dismiss() {
    lastDismissalDate = Date()
  }

  public func cleanup() {
    lastDismissalDate = nil
  }

  public init() {

  }
}

internal class UpdateOperatingSystemCacheMock: UpdateOperatingSystemCacheProtocol {
  var canDisplay: Bool

  func canDisplayAnnouncement() -> Bool {
    return canDisplay
  }

  func dismiss() {

    canDisplay = false
  }

  func cleanup() {
    canDisplay = true
  }

  init(canDisplay: Bool) {
    self.canDisplay = canDisplay
  }
}

extension UpdateOperatingSystemAnnouncement {

  static func mock(
    modelName: String = UnsupportedDevice.iPhone7.rawValue,
    systemWillBeDropped: Bool = true,
    canDisplayAnnouncement: Bool = false
  ) -> UpdateOperatingSystemAnnouncement {
    .init(
      informationProvider: DeviceInformationProviderMock(
        modelName: modelName, systemWillBeDropped: systemWillBeDropped),
      cache: UpdateOperatingSystemCacheMock(canDisplay: canDisplayAnnouncement))
  }

  static func mock(
    modelName: String = UnsupportedDevice.iPhone7.rawValue,
    systemWillBeDropped: Bool = true,
    cache: UpdateOperatingSystemCacheProtocol
  ) -> UpdateOperatingSystemAnnouncement {
    .init(
      informationProvider: DeviceInformationProviderMock(
        modelName: modelName, systemWillBeDropped: systemWillBeDropped),
      cache: cache)
  }
}
