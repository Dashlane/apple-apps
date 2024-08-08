import DashTypes
import DashlaneAPI
import Foundation
import SwiftTreats

public protocol UserTrackingAppActivityReporterCryptoEngineProvider {
  func trackingDataCryptoEngine(forKey data: Data) throws -> CryptoEngine
}

extension UserTrackingAppActivityReporter {
  public init(
    logger: Logger,
    component: Definition.BrowseComponent,
    installationId: LowercasedUUID = DefaultAnalyticsId.analyticsInstallationId,
    localStorageURL: URL = ApplicationGroup.logsLocalStoreURL,
    cryptoEngineProvider: UserTrackingAppActivityReporterCryptoEngineProvider,
    appAPIClient: AppAPIClient,
    platform: Definition.Platform
  ) throws {
    self.init(
      logger: logger,
      component: component,
      installationId: installationId,
      localStorageURL: localStorageURL,
      cryptoEngine: try cryptoEngineProvider.trackingDataCryptoEngine(
        forKey: Self.analyticsLocalStorageEncryptionKey()),
      appAPIClient: appAPIClient,
      platform: platform
    )
  }

  static func analyticsLocalStorageEncryptionKey() -> Data {
    let store = KeychainCustomStore(
      identifier: "com.dashlane.analyticsStoreKey",
      accessGroup: ApplicationGroup.keychainAccessGroup
    )

    guard let key = store.fetch() else {
      let key = Data.random(ofSize: 32)
      try? store.store(key)
      return key
    }
    return key
  }
}

public enum DefaultAnalyticsId {
  enum Key: String {
    case analyticsInstallationId
  }

  public static var analyticsInstallationId: LowercasedUUID {
    var appSharedDefault = SharedUserDefault<String?, String>(
      key: Key.analyticsInstallationId.rawValue,
      userDefaults: ApplicationGroup.dashlaneUserDefaults
    )

    if let storedInstallationId = appSharedDefault.wrappedValue,
      let uuid = LowercasedUUID(uuidString: storedInstallationId)
    {
      return uuid
    }

    if let oldInstallationId = Self.fetchIdAndMigrate() {
      return oldInstallationId
    }

    let installationId = LowercasedUUID()
    appSharedDefault.wrappedValue = installationId.uuidString
    return installationId
  }

  private static func fetchIdAndMigrate() -> LowercasedUUID? {
    var sharedDefault = SharedUserDefault<String?, String>(
      key: Key.analyticsInstallationId.rawValue)
    var appSharedDefault = SharedUserDefault<String?, String>(
      key: Key.analyticsInstallationId.rawValue,
      userDefaults: ApplicationGroup.dashlaneUserDefaults
    )

    if let oldInstallationId = sharedDefault.wrappedValue,
      let uuid = LowercasedUUID(uuidString: oldInstallationId)
    {
      appSharedDefault.wrappedValue = oldInstallationId
      sharedDefault.wrappedValue = nil
      return uuid
    }
    return nil
  }
}

extension Data {
  fileprivate static func random(ofSize size: Int) -> Data {
    var bytes = [Int8](repeating: 0, count: size)
    _ = SecRandomCopyBytes(kSecRandomDefault, size, &bytes)
    return .init(bytes: bytes, count: size)
  }
}
