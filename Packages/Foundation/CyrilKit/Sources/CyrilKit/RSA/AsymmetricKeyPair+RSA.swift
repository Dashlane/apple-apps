import Foundation


extension AsymmetricKeyPair {
    public enum KeySize: Int {
        case rsa512 = 512
        case rsa768 = 768
        case rsa1024 = 1024
        case rsa2048 = 2048
    }
        public init(keySize: KeySize = .rsa2048) throws {

        let keyPairAttr = [kSecAttrKeyType: kSecAttrKeyTypeRSA, kSecAttrKeySizeInBits: keySize.rawValue] as CFDictionary

        guard let privateKey = SecKeyCreateRandomKey(keyPairAttr, nil) else {
            throw RSA.RSAError.keyPairPrivateKeyGenerationFailed
        }
        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
            throw RSA.RSAError.keyPairPublicKeyGenerationFailed
        }

        self.init(publicKey: .init(secKey: publicKey), privateKey: .init(secKey: privateKey))
    }
}

extension SecKey {
    static func makeRSAKey(data: Data, keyClass: CFString) throws -> SecKey {
        var error: Unmanaged<CFError>?
        defer {
            error?.release()
        }
        let attributes = [kSecAttrKeyType: kSecAttrKeyTypeRSA,
                         kSecAttrKeyClass: keyClass] as NSDictionary
        let key = SecKeyCreateWithData((data as NSData), attributes, &error)
        guard error == nil, let key = key else {
            throw RSA.RSAError.keyCreationFailed
        }
        return key
    }
}

public extension PublicKey{
    init(rsaData data: Data) throws {
        let key = try SecKey.makeRSAKey(data: data, keyClass: kSecAttrKeyClassPublic)
        self.secKey = key
    }
}

public extension PrivateKey {
    init(rsaData data: Data) throws {
        let key = try SecKey.makeRSAKey(data: data, keyClass: kSecAttrKeyClassPrivate)
        self.secKey = key
    }
}


fileprivate enum RSAPemComponent: String {
    case publicKeyHeader = "-----BEGIN RSA PUBLIC KEY-----"
    case publicKeyFooter = "-----END RSA PUBLIC KEY-----"
    case privateKeyHeader = "-----BEGIN RSA PRIVATE KEY-----"
    case privateKeyFooter = "-----END RSA PRIVATE KEY-----"
    
}

fileprivate extension String {
    func pemFormat(withHeader header: String, footer: String) -> String {
        var result: [String] = [header]
        let characters = Array(self)
        let lineSize = 64
        stride(from: 0, to: characters.count, by: lineSize).forEach { index in
            result.append(String(characters[index..<min(index+lineSize, characters.count)]))
        }
        result.append(footer)
        return result.joined(separator: "\n")
    }
}

fileprivate extension Data {
    init?(pemString: String, header: String, footer: String) {
        let base64 = pemString.replacingOccurrences(of: header, with: "")
            .replacingOccurrences(of: footer, with: "")
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\r", with: "")
        
        guard let data = Data(base64Encoded: base64) else {
            return nil
        }
        self = data
    }
}

public extension PublicKey {
    init(rsaPemString: String) throws {
        guard let data = Data(pemString: rsaPemString, header: RSAPemComponent.publicKeyHeader.rawValue, footer: RSAPemComponent.publicKeyFooter.rawValue) else {
            throw RSA.RSAError.keyCreationFailed
        }
        
        try self.init(rsaData: data)
    }
    
    func rsaPemString() throws -> String {
        return try data().base64EncodedString().pemFormat(withHeader: RSAPemComponent.publicKeyHeader.rawValue,
                                                          footer: RSAPemComponent.publicKeyFooter.rawValue)
    }
}

public extension PrivateKey {
    init(rsaPemString: String) throws {
        guard let data = Data(pemString: rsaPemString, header: RSAPemComponent.privateKeyHeader.rawValue, footer: RSAPemComponent.privateKeyFooter.rawValue) else {
            throw RSA.RSAError.keyCreationFailed
        }
        
        try self.init(rsaData: data)
    }
    
    func rsaPemString() throws -> String {
        return try data().base64EncodedString().pemFormat(withHeader: RSAPemComponent.privateKeyHeader.rawValue,
                                                          footer: RSAPemComponent.privateKeyFooter.rawValue)
    }
}

