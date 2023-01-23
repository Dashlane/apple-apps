import Foundation

public struct AsymmetricKeyPair {
    public let publicKey: PublicKey
    public let privateKey: PrivateKey
    
    public init(publicKey: PublicKey, privateKey: PrivateKey) {
        self.publicKey = publicKey
        self.privateKey = privateKey
    }
}

public struct PrivateKey {
    public let secKey: SecKey
}

public struct PublicKey {
    public let secKey: SecKey
}

public protocol AsymmetricKeyPairComponent {
    var secKey: SecKey { get }
}

extension PrivateKey: AsymmetricKeyPairComponent { }
extension PublicKey: AsymmetricKeyPairComponent { }

public extension Data {
    init(key: SecKey) throws {
        var error: Unmanaged<CFError>?
        defer {
            error?.release()
        }
        
        guard let keyData = SecKeyCopyExternalRepresentation(key, &error) else {
            throw RSA.RSAError.keyConversionFailed
        }
        if let error = error {
            error.release()
            throw RSA.RSAError.keyConversionFailed
        }
        self = keyData as Data
    }
}

extension AsymmetricKeyPairComponent {
    func data() throws -> Data {
        try .init(key: secKey)
    }
}
