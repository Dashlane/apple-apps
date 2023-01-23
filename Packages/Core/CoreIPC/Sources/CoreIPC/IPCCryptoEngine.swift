import Foundation
import DashTypes
import DashlaneCrypto
import CoreKeychain

public struct IPCCryptoEngine: DashTypes.CryptoEngine {

    @KeychainItemAccessor
    private var communicationCryptoKey: Data?
      
    private func generateCommunicationKey() -> Data {
        Random.randomData(ofSize: 64)
    }
    
    private var cryptoCenter: CryptoCenter
    
    var communicationKey: Data {
        guard let key = communicationCryptoKey, key.count == 64 else {
            let generated = generateCommunicationKey()
            communicationCryptoKey = generated
            return generated
        }
        return key
    }
    
    public init(encryptionKeyId: String,
         accessGroup: String,
         cryptoCenter: CryptoCenter) {
        _communicationCryptoKey = KeychainItemAccessor(identifier: encryptionKeyId, accessGroup: accessGroup)
        self.cryptoCenter = cryptoCenter
    }
    
    public func encrypt(data: Data) -> Data? {
        try? cryptoCenter.encrypt(data: data, with: .key(communicationKey))
    }
    
    public func decrypt(data: Data) -> Data? {
        try? cryptoCenter.decrypt(data: data, with: .key(communicationKey))
    }
}
