import Foundation
import SwiftTreats

enum UnsupportedDevice: String, CaseIterable {
  case iPadGen6 = "iPad7,5"
  case iPadGen6Bis = "iPad7,6"
  case iPadPro105Inch = "iPad7,3"
  case iPadPro105InchBis = "iPad7,4"
  case iPadPro129InchGen2 = "iPad7,1"
  case iPadPro129InchGen2Bis = "iPad7,2"
  case macBookAir13Inch2019 = "MacBookAir8,2"
  case macBookAir13Inch2018 = "MacBookAir8,1"
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
    if #unavailable(iOS 18) {
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
    modelName: String = UnsupportedDevice.iPadGen6.rawValue,
    systemWillBeDropped: Bool = true,
    canDisplayAnnouncement: Bool = false
  ) -> UpdateOperatingSystemAnnouncement {
    .init(
      informationProvider: DeviceInformationProviderMock(
        modelName: modelName, systemWillBeDropped: systemWillBeDropped),
      cache: UpdateOperatingSystemCacheMock(canDisplay: canDisplayAnnouncement))
  }

  static func mock(
    modelName: String = UnsupportedDevice.iPadGen6.rawValue,
    systemWillBeDropped: Bool = true,
    cache: UpdateOperatingSystemCacheProtocol
  ) -> UpdateOperatingSystemAnnouncement {
    .init(
      informationProvider: DeviceInformationProviderMock(
        modelName: modelName, systemWillBeDropped: systemWillBeDropped),
      cache: cache)
  }
}
