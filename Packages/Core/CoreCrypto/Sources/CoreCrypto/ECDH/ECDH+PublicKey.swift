import Foundation
import CryptoKit

extension ECDH.PublicKey {
    init(base64Encoded: String) throws {
        let rawPublicKey = Data(base64Encoded: base64Encoded)!
        try self.init(rawRepresentation: rawPublicKey)
    }
    
    func pemRepresentation() -> String {
        let rawPublicKey = self.rawRepresentation
        let prefix = Data([0x30, 0x2A, 0x30, 0x05, 0x06, 0x03, 0x2B, 0x65, 0x6E, 0x03, 0x21, 0x00])
        let subjectPublicKeyInfo = prefix + rawPublicKey
        let base64PublicKey = subjectPublicKeyInfo.base64EncodedString()
        return "-----BEGIN PUBLIC KEY-----\n" + base64PublicKey + "\n-----END PUBLIC KEY-----"
    }
    
    public func base64EncodedString() -> String {
        let rawPublicKey = self.rawRepresentation
        return rawPublicKey.base64EncodedString()
    }
}
