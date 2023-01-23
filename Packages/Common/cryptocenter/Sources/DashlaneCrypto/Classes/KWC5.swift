import Foundation
import SwiftTreats

public struct KWC5 {

        public static func encrypt(data: Data, withDerivedKey key: Data) -> Data? {
        guard let hash = SHA.hash(data: key, using: .sha512) else {
            return nil
        }
        let newItemKey = hash.subdata(in: hash.startIndex..<hash.startIndex.advanced(by: hash.count / 2))
        let macKey = hash.advanced(by: hash.count / 2)
        let iv = Random.randomByteArray(ofSize: DefaultValues.KWC5.ivLength)
        guard let AESEncryptedData = AES.encrypt(data: data, withKey: newItemKey, mode: .cbc, initializationVector: iv) else {
            return nil
        }
        guard let hmacSHA2Hash = HMAC.hash(of: iv + AESEncryptedData, withKey: macKey, using: .sha256) else {
            return nil
        }
        return iv + Random.randomData(ofSize: DefaultValues.KWC5.placeholderSize) + DefaultValues.KWC5.tag + hmacSHA2Hash + AESEncryptedData
    }

    public static func decrypt(data: Data, withDerivedKey key: Data) -> Data? {
        guard data.count >= DefaultValues.KWC5.ivLength else {
            return nil
        }
        let iv = data[0..<DefaultValues.KWC5.ivLength]
        let index = DefaultValues.KWC5.ivLength + DefaultValues.KWC5.placeholderSize + DefaultValues.KWC5.tag.count
        let hmacSHA2Hash = data[index..<index + 32]
        let encryptedData = data.advanced(by: index + 32)
        guard let hash = SHA.hash(data: key, using: .sha512) else {
            return nil
        }
        let newItemKey = hash.subdata(in: hash.startIndex..<hash.startIndex.advanced(by: hash.count / 2))
        let macKey = hash.advanced(by: hash.count / 2)
        guard let computedHMACSHA2 = HMAC.hash(of: iv + encryptedData, withKey: macKey, using: .sha256) else {
            return nil
        }
        guard hmacSHA2Hash.hexadecimalString == computedHMACSHA2.hexadecimalString else {
            return nil
        }
        return AES.decrypt(data: encryptedData, withKey: newItemKey, mode: .cbc, initializationVector: [UInt8](iv))
    }

}
