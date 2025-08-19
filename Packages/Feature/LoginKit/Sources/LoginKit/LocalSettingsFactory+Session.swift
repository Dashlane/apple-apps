import CoreSession
import CoreSettings
import CoreTypes
import Foundation

extension LocalSettingsFactory {
  public func fetchOrCreateSettings(for session: Session) throws -> LocalSettingsStore {
    try self.fetchOrCreateSettings(for: session.login, cryptoEngine: session.cryptoEngine)
  }
}
