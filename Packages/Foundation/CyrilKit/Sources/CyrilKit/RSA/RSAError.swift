import Foundation

extension RSA {
    public enum RSAError: Error {
        case keyPairPrivateKeyGenerationFailed
        case keyPairPublicKeyGenerationFailed
        case keyCreationFailed
        case keyConversionFailed
        case signFailed
        case encryptFailed
        case decryptFailed
    }
}
