import Foundation
import CoreIPC
import Logger
import AuthenticatorKit
import DashlaneCrypto
import DashTypes
import DashlaneAppKit

extension AuthenticatorDatabaseService {
    convenience init(logger: Logger) {
        self.init(logger: logger,
                  storeURL: ApplicationGroup.otpCodesStoreURL,
                  makeCryptoEngine: { KeychainBasedCryptoEngine.database(encryptionKeyId: $0) })
    }
}

private extension KeychainBasedCryptoEngine {
    static func database(encryptionKeyId: String) -> KeychainBasedCryptoEngine {
        KeychainBasedCryptoEngine(encryptionKeyId: encryptionKeyId,
                                  accessGroup: ApplicationGroup.keychainAccessGroup,
                                  allowKeyRegenerationIfFailure: false,
                                  shouldAccessAfterFirstUnlock: false)
    }
}
