import Foundation
import DashTypes
import SwiftTreats

public struct KeychainBasedCryptoEngine: DashTypes.CryptoEngine {

    private func generateCommunicationKey() -> Data {
        Random.randomData(ofSize: 64)
    }

    private var cryptoCenter: CryptoCenter

    @KeychainItemAccessor
    private var keychainKey: Data?

    private let allowKeyRegenerationIfFailure: Bool

    var encryptionKey: Data {
        guard let key = keychainKey, key.count == 64 else {
            let generated = generateCommunicationKey()
            keychainKey = generated
            return generated
        }
        return key
    }

    public init(encryptionKeyId: String,
                accessGroup: String,
                allowKeyRegenerationIfFailure: Bool,
                shouldAccessAfterFirstUnlock: Bool) {
        self._keychainKey = .init(identifier: encryptionKeyId, accessGroup: accessGroup, shouldAccessAfterFirstUnlock: shouldAccessAfterFirstUnlock)
        self.allowKeyRegenerationIfFailure = allowKeyRegenerationIfFailure
        self.cryptoCenter = CryptoCenter(from: CryptoRawConfig.keyBasedDefault.parametersHeader)!
    }

    public func encrypt(data: Data) -> Data? {
        try? cryptoCenter.encrypt(data: data, with: .key(encryptionKey))
    }

    public func decrypt(data: Data) -> Data? {
        guard let data = try? cryptoCenter.decrypt(data: data, with: .key(encryptionKey)) else {
            if allowKeyRegenerationIfFailure {
                                keychainKey = nil
            }
            return nil
        }

        return data
    }
}
