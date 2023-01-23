import Foundation
import DashlaneAppKit
import CoreSettings
import DashTypes
import CoreSession
import CoreKeychain

extension SettingsManager: LocalSettingsFactory, KeychainSettingsDataProvider {
        public func fetchOrCreateSettings(for login: Login) throws -> LocalSettingsStore {
        let sessionDirectory = try SessionDirectory(baseURL: ApplicationGroup.fiberSessionsURL, login: login)
        let url = try sessionDirectory.storeURL(for: StoreIdentifier.localSettings, in: .app)
        
        guard let settings = self[url] else {
            let fileManager = sessionDirectory.fileManager
            let legacyURL = try URL.makeLegacyUserSettingsURL(login: login)
            
            if fileManager.fileExists(atPath: legacyURL.path)  {
                if fileManager.fileExists(atPath: url.path) {
                    try fileManager.removeItem(at: url)
                }
                try fileManager.moveItem(at: legacyURL, to: url)
            }
            
            return try createSettings(in: url)
        }
        return settings
    }

        public func fetchOrCreateSettings(for login: Login, cryptoEngine: DashTypes.CryptoEngine) throws -> LocalSettingsStore {
        let settings = try fetchOrCreateSettings(for: login)
        self.cryptoEngine = cryptoEngine
        return settings
    }
    
    public func removeSettings(for login: Login) throws {
        let sessionDirectory = try SessionDirectory(baseURL: ApplicationGroup.fiberSessionsURL, login: login)
        let url = try sessionDirectory.storeURL(for: .localSettings, in: .app)
        
        guard let settings = self[url] else {
            return
        }

        remove(settings: settings)
    }

    public func provider(for login: Login) throws -> SettingsDataProvider {
        try fetchOrCreateSettings(for: login).keyed(by: UserLockSettingsKey.self)
    }
}

private extension URL {
    static func makeLegacyUserSettingsURL(login: Login) throws -> URL {
        ApplicationGroup.containerURL.appendingPathComponent(login.email)
    }
}

public class FakeSettingsFactory: LocalSettingsFactory, KeychainSettingsDataProvider {

    var stores: [Login: InMemoryLocalSettingsStore]
    
    public init() {
        stores = [:]
    }
    
    public func fetchOrCreateSettings(for login: Login) throws -> LocalSettingsStore {
        if let store = stores[login] {
            return store
        }
        let store = InMemoryLocalSettingsStore()
        stores[login] = store
        return store
    }

    public func fetchOrCreateSettings(for login: Login, cryptoEngine: DashTypes.CryptoEngine) throws -> LocalSettingsStore {
        return try fetchOrCreateSettings(for: login)
    }
    
    public func fetchOrCreateSettings(for session: Session) throws -> LocalSettingsStore {
        return try fetchOrCreateSettings(for: session.login)
    }
    
    public func removeSettings(for login: Login) throws {
        stores.removeValue(forKey: login)
    }

    public func provider(for login: Login) throws -> SettingsDataProvider {
        try fetchOrCreateSettings(for: login).keyed(by: UserLockSettingsKey.self)
    }
}
