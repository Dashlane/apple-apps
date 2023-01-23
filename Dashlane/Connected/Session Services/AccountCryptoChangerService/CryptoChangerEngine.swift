import Foundation
import DashTypes
import DashlaneCrypto
import CoreSession

class CryptoChangerEngine: DashTypes.CryptoEngine {

        var encryptCryptoEngine: CryptoEngine
        var decryptCryptoEngine: CryptoEngine
    init(current: CryptoEngine, new: CryptoEngine) {

        self.encryptCryptoEngine = new
        self.decryptCryptoEngine = current
    }

    func encrypt(data: Data) -> Data? {
        guard let encryptedData = encryptCryptoEngine.encrypt(data: data) else {
            fatalError("Impossible to Encrypt some data during the Master Password Change Process ... aborting")
        }
        return encryptedData
    }

    func decrypt(data: Data) -> Data? {
        return decryptCryptoEngine.decrypt(data: data)
    }
}
