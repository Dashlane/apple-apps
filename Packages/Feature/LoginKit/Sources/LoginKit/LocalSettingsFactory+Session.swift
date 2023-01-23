import Foundation
import CoreSettings
import DashTypes
import CoreSession

extension LocalSettingsFactory {
    public func fetchOrCreateSettings(for session: Session) throws -> LocalSettingsStore {
        try self.fetchOrCreateSettings(for: session.login, cryptoEngine: session.cryptoEngine)
    }
}
