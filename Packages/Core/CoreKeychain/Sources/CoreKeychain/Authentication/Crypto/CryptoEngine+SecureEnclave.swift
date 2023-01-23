import Foundation
import CryptoKit
import DashTypes

private enum CryptoKey {
    case secureEnclaveKeys(SecureEnclaveKeys)
    case dashlaneKey
}

extension KeychainCryptoEngine {
    func encrypt(_ data: Data, accessMode: KeychainAccessMode, accessGroup: String) -> Data? {
        switch accessMode {
        case .afterBiometricAuthentication:
                        return encrypt(data, using: .dashlaneKey)
        case .whenDeviceUnlocked:
            switch SecureEnclave.cryptoKeys(accessGroup: accessGroup) {
            case .available(let keys):
                return encrypt(data, using: .secureEnclaveKeys(keys))
            case .unavailable:
                return encrypt(data, using: .dashlaneKey)
            }
        }
    }

    func decrypt(_ data: Data, accessGroup: String) -> Data? {
        switch SecureEnclave.cryptoKeys(accessGroup: accessGroup) {
        case .available(let keys):
                        if let decryptedData = decrypt(data, using: .secureEnclaveKeys(keys)) {
                return decryptedData
            } else {
                                                                return decrypt(data, using: .dashlaneKey)
            }
        case .unavailable:
            return decrypt(data, using: .dashlaneKey)
        }
    }
}

extension KeychainCryptoEngine {
    private func encrypt(_ data: Data, using cryptoKey: CryptoKey) -> Data? {
        switch cryptoKey {
        case .secureEnclaveKeys(let keys):
            return SecKeyCreateEncryptedData(keys.publicKey, .eciesEncryptionStandardX963SHA256AESGCM, data as CFData, nil) as Data?
        case .dashlaneKey:
            return encrypt(data: data, using: ApplicationSecrets.Keychain.key)
        }
    }

    private func decrypt(_ data: Data, using cryptoKey: CryptoKey) -> Data? {
        switch cryptoKey {
        case .secureEnclaveKeys(let keys):
            return SecKeyCreateDecryptedData(keys.privateKey, .eciesEncryptionStandardX963SHA256AESGCM, data as CFData, nil) as Data?
        case .dashlaneKey:
            return decrypt(data: data, using: ApplicationSecrets.Keychain.key)
        }
    }
}
