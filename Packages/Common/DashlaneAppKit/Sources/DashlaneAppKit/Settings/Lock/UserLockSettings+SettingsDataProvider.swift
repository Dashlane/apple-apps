import Foundation
import CoreKeychain
import CoreSettings

extension UserLockSettings: SettingsDataProvider {

        public func masterKeyExpirationDate() throws -> Date {
        #if targetEnvironment(macCatalyst) || os(macOS)
        let expiration: Date? = self[.mpKeychainStorageExpirationDate]
        return expiration ?? .distantFuture
        #else
        return .distantFuture
        #endif
    }

    public func saveMasterKeyExpirationDate(_ expirationDate: Date) throws {
        self[.mpKeychainStorageExpirationDate] = expirationDate
    }

    public func removeMasterKeyExpirationDate() {
        deleteValue(for: .mpKeychainStorageExpirationDate)
    }
}
