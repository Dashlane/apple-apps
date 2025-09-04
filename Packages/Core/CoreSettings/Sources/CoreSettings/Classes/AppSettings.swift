import CoreTypes
import Foundation
import SwiftTreats

public class AppSettings {
  public enum Key: String, CustomStringConvertible {
    case anonymousDeviceId = "KWApplicationUniqueId"
    case deviceId = "KWApplicationDeviceUniqueId"
    case uniqueApplicationIdAlreadyCalled = "uniqueApplicationIdIsAlreadyCalled"
    case dashlaneFirstInstallDate = "dashlaneFirstInstallDate"
    case unauthenticatedABTestingCache
    case versionValidityAlertLastShownDate
    case deleteLocalData = "DELETE_LOCAL_DATA_NEXT_LAUNCH"

    public var description: String {
      return rawValue
    }
  }

  @SharedUserDefault(key: Key.deviceId)
  public var deviceId: String?

  @SharedUserDefault(key: Key.anonymousDeviceId, default: UUID().uuidString.onlyAlphanumeric())
  public var anonymousDeviceId: String

  @SharedUserDefault(key: Key.dashlaneFirstInstallDate)
  public var installationDate: Date?

  @SharedUserDefault(key: Key.unauthenticatedABTestingCache)
  public var abTestingCache: Data?

  @SharedUserDefault(key: Key.versionValidityAlertLastShownDate)
  public var versionValidityAlertLastShownDate: Date?

  @SharedUserDefault(key: Key.uniqueApplicationIdAlreadyCalled, default: 0)
  private var isUniqueApplicationIdAlreadyCalledInt: Int

  private var isUniqueApplicationIdAlreadyCalled: Bool {
    get {
      return isUniqueApplicationIdAlreadyCalledInt == 1
    }
    set {
      isUniqueApplicationIdAlreadyCalledInt = newValue ? 1 : 0
    }
  }

  public lazy var isFirstLaunch: Bool = { !isUniqueApplicationIdAlreadyCalled }()

  public func configure() {
    if deviceId == nil {
      self.deviceId = createDeviceId(withConsistentPart: nil)
    }

    guard isFirstLaunch else {
      return
    }
    isUniqueApplicationIdAlreadyCalled = true
    self.installationDate = Date()
  }

  private func createDeviceId(withConsistentPart consistentPart: String?) -> String {
    let reversedConsistentPart = consistentPart?.reversed()
    let obfuscatedValue = (reversedConsistentPart.map(String.init) ?? UUID().uuidString).md5()
    return obfuscatedValue ?? UUID().uuidString
  }

  public init() {

  }
}
