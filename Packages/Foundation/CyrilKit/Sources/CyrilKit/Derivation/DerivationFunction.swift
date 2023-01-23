import Foundation

public protocol DerivationFunction {
                            func derivateKey<V: ContiguousBytes, S: ContiguousBytes>(from password: V, salt: S) throws -> Data
}

enum KeyDerivaterError: Error {
    case stringToCStringFailed
    case derivationFailed(internalError: Error)
}

public extension DerivationFunction {
    func derivateKey(from password: String, salt: Data) throws -> Data {
        guard var passwordBytes = password.data(using: .utf8) else {
            throw KeyDerivaterError.stringToCStringFailed
        }
        
                passwordBytes.removeLast()
        return try derivateKey(from: passwordBytes, salt: salt)
    }
}
