import Foundation

public struct KWC3 {

        static func bytesToKey(passwordSalt: Data) -> Data? {
        guard let hash = SHA.hash(data: passwordSalt, using: .sha1) else {
            return nil
        }
        var buffer = [hash]
        for index in 1..<4 {
            buffer.append(SHA.hash(data: buffer[index - 1] + passwordSalt, using: .sha1)!)
        }
        return Data([UInt8]((buffer.flatMap { $0 })[32..<48]))
    }

    static public func encrypt(data: Data, salt: Data, derivedKey: Data) -> Data? {
        let buffer = derivedKey + Data( salt[0..<8])
        guard let iv = bytesToKey(passwordSalt: buffer) else {
            return nil
        }
        guard let encryptedData = AES.encrypt(data: data, withKey: derivedKey, mode: AESMode.cbc, initializationVector: [UInt8](iv)) else {
            return nil
        }
        return salt + DefaultValues.KWC3.tag + encryptedData
    }

    static public func decrypt(data: Data, withDerivedKey derivedKey: Data) -> Data? {

        guard data.count >= DefaultValues.KWC3.saltLength else {
            return nil
        }
        let salt = data[0..<DefaultValues.KWC3.saltLength]

        let buffer = derivedKey + salt[0..<8]
        guard let iv = bytesToKey(passwordSalt: buffer) else {
            return nil
        }
        let cipheredData = data.advanced(by: salt.count + DefaultValues.KWC3.tag.count)
        return AES.decrypt(data: cipheredData,
                           withKey: derivedKey,
                           initializationVector: [UInt8](iv))
    }

}
