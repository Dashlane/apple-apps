import Foundation
import CoreIPC
import Logger
import AuthenticatorKit
import DashlaneAppKit

extension AuthenticatorDatabaseService {
        convenience init(logger: Logger) {
        self.init(logger: logger,
                  storeURL: ApplicationGroup.otpCodesStoreURL,
                  makeCryptoEngine: { IPCCryptoEngine(encryptionKeyId: $0) },
                  shouldLoadDatabase: false)
#if DEBUG
                if let testing = AuthenticatorTesting(logger: logger, persistor: persistor) {
            testing.performAction()
        }
#endif
                load()
    }
}
