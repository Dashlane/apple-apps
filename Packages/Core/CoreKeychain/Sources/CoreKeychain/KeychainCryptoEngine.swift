import Foundation

public protocol KeychainCryptoEngine {
    func encrypt(data: Data, using password: String) -> Data?
    func decrypt(data: Data, using password: String) -> Data?
}
