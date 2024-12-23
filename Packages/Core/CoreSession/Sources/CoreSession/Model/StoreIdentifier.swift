import DashTypes
import Foundation

public enum StoreIdentifier: String, CaseIterable {
  case personalData
  case galactica
  case usageLogs
  case icons
  case sharing
  case localSettings
  case premiumStatus

  public var sharedAcrossTargets: Bool {
    switch self {
    case .personalData, .sharing:
      return false
    default:
      return true
    }
  }
}

extension SessionDirectory {
  public func storeURL(for identifier: StoreIdentifier, in target: BuildTarget) throws -> URL {
    if identifier.sharedAcrossTargets || target == .app {
      return try storeURLForData(identifiedBy: identifier.rawValue)
    } else {
      return try storeURLForData(
        inExtensionNamed: target.rawValue, identifiedBy: identifier.rawValue)
    }
  }

  public func legacyExtensionStoreURL(for identifier: StoreIdentifier) -> URL {
    return legacyExtensionStoreURLForData(identifiedBy: identifier.rawValue)
  }
}
