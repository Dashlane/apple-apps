import Foundation
import SecurityDashboard
import DashlaneCrypto

public struct DataLeakInformationDecryptor: DataLeakInformationDataDecryptor {
    let privateKey: SecKey

    public func decrypt(data: Data, using encryptedCipherKey: Data) -> Data? {
                let decryptedKey = RSA.decrypt(data: encryptedCipherKey, withPrivateKey: privateKey, withAlgorithm: .rsaEncryptionOAEPSHA1)!

        guard let center = CryptoCenter(from: data) else {
            assertionFailure("Could not create center from data. Something might be wrong with data sent.")
            return nil
        }

        do {
            let decrypted = try center.decrypt(data: data, with: .key(decryptedKey))
            return decrypted
        } catch {
            assertionFailure("Could not decrypt the data.")
        }

        return nil
    }
}
