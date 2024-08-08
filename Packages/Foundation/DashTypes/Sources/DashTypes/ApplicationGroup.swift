import Foundation
import SwiftTreats

public struct ApplicationGroup {

  public static var id: String { "group.dashlane.sharedContainer" }

  public static var dashlaneAppId: String { "group.dashlane.dashlaneAppContainer" }

  public static var keychainAccessGroup: String { "5P72E3GC48.com.dashlane.dashlaneKeychainSuite" }

  public static var userDefaults: UserDefaults {
    guard let userDefaults = UserDefaults(suiteName: id) else {
      fatalError("Impossible to get the URL")
    }
    return userDefaults
  }

  public static var containerURL: URL {
    guard let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: id)
    else {
      fatalError(
        "Impossible to get the URL for \(id), the id may be invalid for this configuration")
    }
    return url
  }

  public static var documentsURL: URL {
    return containerURL.appendingPathComponent("Documents")
  }

  public static var fiberSessionsURL: URL {
    return containerURL.appendingPathComponent("FiberSessions", isDirectory: true)
  }

  public static var logsLocalStoreURL: URL {
    return documentsURL.appendingPathComponent("logsStore", isDirectory: true)
  }

  public static var activityLogsLocalStoreURL: URL {
    return documentsURL.appendingPathComponent("activityLogsStore", isDirectory: true)
  }

  public static var otpCodesStoreURL: URL {
    return containerURL.appendingPathComponent("dashlaneAuthenticatorDB.json")
  }

  public static var authenticatorAppId: String {
    return "group.dashlane.authenticatorAppContainer"
  }

  public static var dashlaneUserDefaults: UserDefaults {
    guard let userDefaults = UserDefaults(suiteName: dashlaneAppId) else {
      fatalError("Impossible to get the URL")
    }
    return userDefaults
  }

  public static var authenticatorUserDefaults: UserDefaults {
    guard let userDefaults = UserDefaults(suiteName: authenticatorAppId) else {
      fatalError("Impossible to get the URL")
    }
    return userDefaults
  }

  public static var authenticatorLogsLocalStoreURL: URL {
    return documentsURL.appendingPathComponent("authenticatorLogsStore", isDirectory: true)
  }

  public static var authenticatorStandaloneStoreURL: URL {
    return documentsURL.appendingPathComponent("authenticatorStore", isDirectory: true)
  }
}

extension SharedUserDefault {
  public init(key: Key, `default` defaultValue: T) {
    self.init(key: key, default: defaultValue, userDefaults: ApplicationGroup.userDefaults)
  }

  public init<P>(key: Key, `default` defaultValue: P? = nil) where T == P? {
    self.init(key: key, default: defaultValue, userDefaults: ApplicationGroup.userDefaults)
  }
}
