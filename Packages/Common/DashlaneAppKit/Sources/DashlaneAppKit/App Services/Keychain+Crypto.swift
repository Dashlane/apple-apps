import Foundation
import DashlaneCrypto
import CoreKeychain
import DashTypes
import CoreSession

extension CryptoCenter: KeychainCryptoEngine {
    public func encrypt(data: Data, using password: String) -> Data? {
        let secret = EncryptionSecret.password(password)
        do {
            let encryptedData = try encrypt(data: data, with: secret)
            guard let data = encryptedData else { return nil }
            return data
        } catch {
            return nil
        }
    }

    public func decrypt(data: Data, using password: String) -> Data? {
        let secret = EncryptionSecret.password(password)
        do {
            let decryptedData = try CryptoCenter(from: data)?.decrypt(data: data, with: secret)
            guard let data = decryptedData else { return nil }
            return data
        } catch {
            return nil
        }
    }
}

