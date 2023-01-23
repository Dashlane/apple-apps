import Foundation
import Security

public struct RSA {

    public static func sign(_ data: Data, withPrivateKey privateKey: SecKey, algorithm: SecKeyAlgorithm = .rsaSignatureMessagePKCS1v15SHA256) -> Data? {
        var error: Unmanaged<CFError>?
        let signedData = SecKeyCreateSignature(privateKey,
                                               algorithm,
                                               data as CFData,
                                               &error)
        if let error = error {
            error.release()
            return nil
        }
        return signedData as Data?
    }

    public static func verify(_ signature: Data, withData data: Data, withPublicKey publicKey: SecKey, algorithm: SecKeyAlgorithm = .rsaSignatureMessagePKCS1v15SHA256) -> Bool {
        var error: Unmanaged<CFError>?
        let result = SecKeyVerifySignature(publicKey,
                                           algorithm,
                                           data as CFData,
                                           signature as CFData,
                                           &error)
        if let error = error {
            error.release()
            return false
        }
        return result
    }

    public static func generateRSAKeyPair() throws -> (privateKey: SecKey, publicKey: SecKey) {
        let keyPairAttr = [kSecAttrKeyType: kSecAttrKeyTypeRSA,
                           kSecAttrKeySizeInBits: NSNumber(value: DefaultValues.RSA.keySize)] as NSDictionary

        guard let privateKey = SecKeyCreateRandomKey(keyPairAttr as CFDictionary, nil) else {
            throw RSAError.KeyPairGeneration
        }


        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
            throw RSAError.KeyPairGeneration
        }

        return (privateKey, publicKey)
    }

    private static func blockOffset(forPadding padding: SecPadding) -> Int {
        if padding == .OAEP {
            return 66
        } else if padding == .sigRaw {
            return 0
        } else {
            return 11
        }
    }

    private static func encrypt(blockOfData data: Data, withPublicKey key: SecKey, withAlgorithm algorithm: SecKeyAlgorithm) -> Data? {
        var error: Unmanaged<CFError>?
        defer {
            if let error = error {
                error.release()
            }
        }
        guard SecKeyIsAlgorithmSupported(key, .encrypt, algorithm) == true else {
            return nil
        }
        guard let encryptedData = SecKeyCreateEncryptedData(key, algorithm, data as CFData, &error) else {
            return nil
        }
        return encryptedData as Data
    }

    public static func encrypt(data dataToEncrypt: Data,
                               withPublicKey key: SecKey,
                               withAlgorithm algorithm: SecKeyAlgorithm = .rsaEncryptionOAEPSHA256,
                               withPadding padding: SecPadding = .OAEP) -> Data? {
        let blockLength = SecKeyGetBlockSize(key) - blockOffset(forPadding: padding)
        guard dataToEncrypt.count > blockLength else {
            return encrypt(blockOfData: dataToEncrypt, withPublicKey: key, withAlgorithm: algorithm)
        }
        var encryptedData = Data()
        var position = 0
        while dataToEncrypt.count - position > blockLength {
            let range = Range(uncheckedBounds: (position, position + blockLength))
            let dataBlock = dataToEncrypt.subdata(in: range)
            guard let encryptedBlock = encrypt(blockOfData: dataBlock, withPublicKey: key, withAlgorithm: algorithm) else {
                return nil
            }
            encryptedData.append(encryptedBlock)
            position = position + blockLength
        }
        guard !(position..<dataToEncrypt.count).isEmpty else {
            return encryptedData
        }
        let dataBlock = dataToEncrypt.subdata(in: position..<dataToEncrypt.count)
        guard let encryptedBlock = encrypt(blockOfData: dataBlock, withPublicKey: key, withAlgorithm: algorithm) else {
            return nil
        }
        encryptedData.append(encryptedBlock)
        return encryptedData
    }

    private static func decrypt(blockOfData data: Data, withPrivateKey key: SecKey, withAlgorithm algorithm: SecKeyAlgorithm) -> Data? {
        var error: Unmanaged<CFError>?
        defer {
            if let error = error {
                error.release()
            }
        }
        guard SecKeyIsAlgorithmSupported(key, .decrypt, algorithm) == true else {
            return nil
        }
        guard let decryptedData = SecKeyCreateDecryptedData(key, algorithm, data as CFData, &error) else {
            return nil
        }
        return decryptedData as Data
    }

    public static func decrypt(data dataToDecrypt: Data,
                               withPrivateKey key: SecKey,
                               withAlgorithm algorithm: SecKeyAlgorithm = .rsaEncryptionOAEPSHA256) -> Data? {
        let blockLength = SecKeyGetBlockSize(key)
        guard dataToDecrypt.count > blockLength else {
            return decrypt(blockOfData: dataToDecrypt, withPrivateKey: key, withAlgorithm: algorithm)
        }
        var decryptedData = Data()
        var position = 0
        while dataToDecrypt.count - position > blockLength {
            let range = Range(uncheckedBounds: (position, position + blockLength))
            let dataBlock = dataToDecrypt.subdata(in: range)
            guard let decryptedBlock = decrypt(blockOfData: dataBlock, withPrivateKey: key, withAlgorithm: algorithm) else {
                return nil
            }
            decryptedData.append(decryptedBlock)
            position = position + blockLength
        }
        guard !(position..<dataToDecrypt.count).isEmpty else {
            return decryptedData
        }
        let dataBlock = dataToDecrypt.subdata(in: position..<dataToDecrypt.count)
        guard let decryptedBlock = decrypt(blockOfData: dataBlock, withPrivateKey: key, withAlgorithm: algorithm) else {
            return nil
        }
        decryptedData.append(decryptedBlock)
        return decryptedData
    }

}
