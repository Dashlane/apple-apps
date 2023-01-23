import Foundation
import DashTypes

public protocol LocalSettingsFactory {
    func fetchOrCreateSettings(for login: Login) throws -> LocalSettingsStore
    func fetchOrCreateSettings(for login: Login, cryptoEngine: CryptoEngine) throws -> LocalSettingsStore
    func removeSettings(for login: Login) throws
}
