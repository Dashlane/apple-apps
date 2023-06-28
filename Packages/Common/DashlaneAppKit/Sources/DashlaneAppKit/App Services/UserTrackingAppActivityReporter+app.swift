import Foundation
import CoreUserTracking
import DashTypes
import SwiftTreats
import DashlaneCrypto
import CoreKeychain
import DashlaneAPI

extension UserTrackingAppActivityReporter {
    public init(logger: Logger,
                component: Definition.BrowseComponent,
                installationId: LowercasedUUID = Self.analyticsInstallationId,
                localStorageURL: URL = ApplicationGroup.logsLocalStoreURL,
                appAPIClient: AppAPIClient,
                platform: Definition.Platform) {
        self.init(logger: logger,
                  component: component,
                  installationId: installationId,
                  localStorageURL: localStorageURL,
                  cryptoEngine: Self.localStorageCryptoEngine,
                  appAPIClient: appAPIClient,
                  platform: platform)
    }
}

extension UserTrackingAppActivityReporter {
    enum Key: String {
        case analyticsInstallationId
    }

        public static var analyticsInstallationId: LowercasedUUID {

        var appSharedDefault = SharedUserDefault<String?, String>(key: Key.analyticsInstallationId.rawValue, userDefaults: ApplicationGroup.dashlaneUserDefaults)

        if let storedInstallationId = appSharedDefault.wrappedValue,
           let uuid = LowercasedUUID(uuidString: storedInstallationId) {
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
        var sharedDefault = SharedUserDefault<String?, String>(key: Key.analyticsInstallationId.rawValue)
        var appSharedDefault = SharedUserDefault<String?, String>(key: Key.analyticsInstallationId.rawValue, userDefaults: ApplicationGroup.dashlaneUserDefaults)

                if let oldInstallationId = sharedDefault.wrappedValue, let uuid = LowercasedUUID(uuidString: oldInstallationId) {
            appSharedDefault.wrappedValue = oldInstallationId
            sharedDefault.wrappedValue = nil
            return uuid
        }
        return nil
    }

    private static var localStorageCryptoEngine: DashTypes.CryptoEngine {
        return UserTrackingLocalStoreCryptoEngine(key: Self.analyticsLocalStorageEncryptionKey)
    }

        private static var analyticsLocalStorageEncryptionKey: Data {
        let store = KeychainCustomStore(identifier: "com.dashlane.analyticsStoreKey",
                                        accessGroup: ApplicationGroup.keychainAccessGroup)
        guard let key = store.fetch() else {
            let key = Random.randomData(ofSize: 32)
            try? store.store(key)
            return key
        }
        return key
    }
}

struct UserTrackingLocalStoreCryptoEngine: CryptoEngine {

    let key: Data
        let keyBasedCryptoCenter: CryptoCenter = CryptoCenter(configuration: .kwc5)

    public init(key: Data) {
        self.key = key
    }

    public func decrypt(data: Data) -> Data? {
        return try? keyBasedCryptoCenter.decrypt(data: data, with: .key(key))
    }

    public func encrypt(data: Data) -> Data? {
        return try? keyBasedCryptoCenter.encrypt(data: data, with: .key(key))
    }
}
