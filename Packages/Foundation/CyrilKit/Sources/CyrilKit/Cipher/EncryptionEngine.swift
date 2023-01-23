import Foundation

public protocol EncryptionEngine: Encrypter & Decrypter { }

public protocol Encrypter {
    func encrypt(_ data: Data) throws -> Data
}

public protocol Decrypter {
    func decrypt(_ data: Data) throws -> Data
}
