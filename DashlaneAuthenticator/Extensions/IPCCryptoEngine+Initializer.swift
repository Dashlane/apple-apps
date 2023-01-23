import Foundation
import CoreIPC
import DashlaneCrypto
import DashlaneAppKit
import DashTypes

extension IPCCryptoEngine {
    init(encryptionKeyId: String) {
        self.init(encryptionKeyId: encryptionKeyId,
                  accessGroup: ApplicationGroup.keychainAccessGroup,
                  cryptoCenter: CryptoCenter(from: CryptoRawConfig.keyBasedDefault.parametersHeader)!)
    }
    
}
