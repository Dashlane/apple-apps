import Foundation
import CommonCrypto

public struct HashedMasterPasswordVerification {
    
        public static func `is`(hashedMasterPassword base64hash: String, equalTo masterPassword: String) -> Bool {
        guard let base64hashData = Data(base64Encoded: base64hash) else {
            return false
        }
        
                let saltLength: Int = 32
        
                let hashVersionLength: Int = 4
        
                let hashedDataLength: Int = 32
        
        guard base64hashData.count == saltLength + hashVersionLength + hashedDataLength else {
            return false
        }
        
                var salt = [UInt8](repeating: 0, count: saltLength)
        base64hashData.copyBytes(to: &salt, count: saltLength)
        
                let hashVersion = "KWH1".utf8.map { UInt8($0) }
        
                var hashVersionSource = [UInt8](repeating: 0, count: hashVersionLength)
        base64hashData.copyBytes(to: &hashVersionSource, from: saltLength..<saltLength + hashVersionLength)
        guard hashVersionSource == hashVersion else {
            return false
        }
        
                var hashedDataSource = [UInt8](repeating: 0, count: hashedDataLength)
        base64hashData.copyBytes(to: &hashedDataSource, from: saltLength + hashVersionLength..<base64hashData.count)
        
                let hashedMasterPassword = hashMasterPassword(masterPassword,
                                           saltData: salt,
                                           saltLength: saltLength,
                                           hashedDataLength: hashedDataLength)
        
                return hashedMasterPassword == hashedDataSource
    }
    
    private static func hashMasterPassword(_ localPassword: String,
                                          saltData: [UInt8],
                                          saltLength: Int,
                                          hashedDataLength: Int) -> [UInt8]? {
        
                guard let data = localPassword.data(using: .utf8),
            let sha512Hash = SHA.hash(data: data, using: .sha512) else {
            return nil
        }
        
                let numberOfIterations = 10204
        
        guard let result = Derivation.PBKDF2(of: sha512Hash.map { Int8(bitPattern: $0) },
                                             using: .sha1,
                                             derivedKeyLength: hashedDataLength,
                                             salt: saltData,
                                             numberOfIterations: numberOfIterations) else {
            return nil
        }
        
        var hashedData = [UInt8](repeating: 0, count: hashedDataLength)
        result.copyBytes(to: &hashedData, from: 0..<hashedDataLength)
        
        return hashedData
    }
}
