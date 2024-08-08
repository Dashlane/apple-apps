import AuthenticatorKit
import CoreCrypto
import CoreIPC
import DashTypes
import Foundation
import Logger

extension AuthenticatorDatabaseService {
  convenience init(logger: Logger) {
    self.init(
      logger: logger,
      storeURL: ApplicationGroup.otpCodesStoreURL,
      makeCryptoEngine: { KeychainBasedCryptoEngine.database(encryptionKeyId: $0) },
      shouldLoadDatabase: false)
    #if DEBUG
      if let testing = AuthenticatorTesting(logger: logger, persistor: persistor) {
        testing.performAction()
      }
    #endif
    load()
  }
}

extension KeychainBasedCryptoEngine {
  fileprivate static func database(encryptionKeyId: String) -> KeychainBasedCryptoEngine {
    KeychainBasedCryptoEngine(
      encryptionKeyId: encryptionKeyId,
      accessGroup: ApplicationGroup.keychainAccessGroup,
      allowKeyRegenerationIfFailure: false,
      shouldAccessAfterFirstUnlock: false)
  }
}
