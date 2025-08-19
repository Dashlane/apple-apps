import AuthenticatorKit
import CoreCrypto
import CoreIPC
import CoreTypes
import Foundation
import LogFoundation
import Logger

extension AuthenticatorDatabaseService {
  convenience init(logger: Logger) {
    self.init(
      logger: logger,
      storeURL: ApplicationGroup.otpCodesStoreURL,
      makeCryptoEngine: { KeychainBasedCryptoEngine.database(encryptionKeyId: $0) })
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
