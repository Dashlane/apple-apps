import Foundation
import SwiftTreats

enum UnsupportedDevice: String, CaseIterable {
  case iPhoneX = "iPhone10,3"
  case iPhoneXBis = "iPhone10,6"
  case iPhone8Plus = "iPhone10,2"
  case iPhone8PlusBis = "iPhone10,5"
  case iPhone8 = "iPhone10,1"
  case iPhone8Bis = "iPhone10,4"
  case iPadGen5 = "iPad6,11"
  case iPadGen5Bis = "iPad6,12"
  case iPadPro97Inch = "iPad6,3"
  case iPadPro97InchBis = "iPad6,4"
  case iPadPro129InchGen1 = "iPad6,7"
  case iPadPro129InchGen1Bis = "iPad6,8"
  case macBookPro15Inch2017 = "MacBookPro14,3"
  case macBookPro13Inch20174Thunderbolt = "MacBookPro14,1"
  case macBookPro13Inch20172Thunderbolt = "MacBookPro14,2"
  case macBook12Inch2017 = "MacBook10,1"
  case iMacPro2017 = "iMacPro1,1"
  case iMac5K21Inch2017 = "iMac18,3"
  case iMac4K215Inch2017 = "iMac18,2"
  case iMac215Inch2017 = "iMac18,1"
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
    if #unavailable(iOS 17) {
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
    modelName: String = UnsupportedDevice.iPhone8.rawValue,
    systemWillBeDropped: Bool = true,
    canDisplayAnnouncement: Bool = false
  ) -> UpdateOperatingSystemAnnouncement {
    .init(
      informationProvider: DeviceInformationProviderMock(
        modelName: modelName, systemWillBeDropped: systemWillBeDropped),
      cache: UpdateOperatingSystemCacheMock(canDisplay: canDisplayAnnouncement))
  }

  static func mock(
    modelName: String = UnsupportedDevice.iPhone8.rawValue,
    systemWillBeDropped: Bool = true,
    cache: UpdateOperatingSystemCacheProtocol
  ) -> UpdateOperatingSystemAnnouncement {
    .init(
      informationProvider: DeviceInformationProviderMock(
        modelName: modelName, systemWillBeDropped: systemWillBeDropped),
      cache: cache)
  }
}
