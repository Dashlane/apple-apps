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
                  makeCryptoEngine: { IPCCryptoEngine(encryptionKeyId: $0) })
    }
}

extension IPCCryptoEngine {
    init(encryptionKeyId: String) {
        self.init(encryptionKeyId: encryptionKeyId,
                  accessGroup: ApplicationGroup.keychainAccessGroup,
                  cryptoCenter: CryptoCenter(from: CryptoRawConfig.keyBasedDefault.parametersHeader)!)
    }

}
