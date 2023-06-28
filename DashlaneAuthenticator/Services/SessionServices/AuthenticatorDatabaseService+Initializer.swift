import Foundation
import CoreIPC
import Logger
import AuthenticatorKit
import DashTypes
import DashlaneCrypto

extension AuthenticatorDatabaseService {
        convenience init(logger: Logger) {
        self.init(logger: logger,
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

private extension KeychainBasedCryptoEngine {
    static func database(encryptionKeyId: String) -> KeychainBasedCryptoEngine {
        KeychainBasedCryptoEngine(encryptionKeyId: encryptionKeyId,
                                  accessGroup: ApplicationGroup.keychainAccessGroup,
                                  allowKeyRegenerationIfFailure: false,
                                  shouldAccessAfterFirstUnlock: false)
    }
}
