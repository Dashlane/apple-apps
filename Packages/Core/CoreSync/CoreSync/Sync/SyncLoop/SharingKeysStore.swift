import Foundation
import CyrilKit
import DashTypes

public actor SharingKeysStore {
    let url: URL
    let localCryptoEngine: CryptoEngine
    let privateKeyRemoteCryptoEngine: CryptoEngine
    let logger: Logger

    public var needsKey: Bool {
        return keyPairValue == nil
    }
    private var keyPairValue: AsymmetricKeyPair?

    public init(url: URL,
                localCryptoEngine: CryptoEngine,
                privateKeyRemoteCryptoEngine: CryptoEngine,
                logger: Logger) async {
        self.url = url
        self.localCryptoEngine = localCryptoEngine
        self.privateKeyRemoteCryptoEngine = privateKeyRemoteCryptoEngine
        self.logger = logger
        self.loadFromDisk()
    }

    public func keyPair() -> AsymmetricKeyPair? {
        return keyPairValue
    }

    private func loadFromDisk() {
        do {
            guard FileManager.default.fileExists(atPath: url.path) else {
                return
            }
            let data = try Data(contentsOf: url).decrypt(using: localCryptoEngine)
            let sharingKeys = try JSONDecoder().decode(PersistedSharingKeys.self, from: data)

            keyPairValue = try AsymmetricKeyPair(sharingKeys)
        } catch {
            logger.fatal("cannot load sharing keys from disk", error: error)
        }
    }

    func save(_ sharingKeys: SharingKeys) {
        do {
            let keyPair = try AsymmetricKeyPair(sharingKeys: sharingKeys, privateKeyCryptoEngine: privateKeyRemoteCryptoEngine)
            self.keyPairValue = keyPair
            try JSONEncoder()
                .encode(keyPair.makePersistedSharingKeys())
                .encrypt(using: localCryptoEngine)
                .write(to: url, options: [.atomic])
        } catch {
            logger.fatal("cannot save sharing keys on disk", error: error)
        }
    }

    func save(_ keyPair: AsymmetricKeyPair) {
        self.keyPairValue = keyPair
    }
}

public enum SharingKeysError: Error {
    case cannotParseSharingKeys
    case cannotGenerateSharingKeys
}

public extension AsymmetricKeyPair {
    static func makeAccountDefaultKeyPair() throws -> AsymmetricKeyPair {
        return try AsymmetricKeyPair(keySize: .rsa2048)
    }
}

public extension SharingKeys {
    static func makeAccountDefault(privateKeyCryptoEngine: CryptoEngine) throws -> SharingKeys {
        return try AsymmetricKeyPair(keySize: .rsa2048).makeSharingKeys(privateKeyCryptoEngine: privateKeyCryptoEngine)
    }
}

private struct PersistedSharingKeys: Codable {
    let publicKey: String
    let privateKey: String
}

fileprivate extension AsymmetricKeyPair {
    init(_ persistedSharingKeys: PersistedSharingKeys) throws {
        let publicKey = try PublicKey(rsaPemString: persistedSharingKeys.publicKey)
        let privateKey = try PrivateKey(rsaPemString: persistedSharingKeys.privateKey)
        self.init(publicKey: publicKey, privateKey: privateKey)
    }

    func makePersistedSharingKeys() throws -> PersistedSharingKeys {
        let publickey = try publicKey.rsaPemString()
        let privateKey = try privateKey.rsaPemString()

        return PersistedSharingKeys(publicKey: publickey, privateKey: privateKey)
    }
}

public extension AsymmetricKeyPair {
    init(sharingKeys: SharingKeys, privateKeyCryptoEngine: CryptoEngine) throws {
        let publicKey = try PublicKey(rsaPemString: sharingKeys.publicKey)

        guard let encryptedPrivateKey = Data(base64Encoded: sharingKeys.encryptedPrivateKey),
              case  let decryptedPrivateKey = try encryptedPrivateKey.decrypt(using: privateKeyCryptoEngine),
              let privateKeyPemString = String(data: decryptedPrivateKey, encoding: .utf8) else {
            throw SharingKeysError.cannotParseSharingKeys
        }

        let privateKey = try PrivateKey(rsaPemString: privateKeyPemString)
        self.init(publicKey: publicKey, privateKey: privateKey)
    }

    func makeSharingKeys(privateKeyCryptoEngine: CryptoEngine) throws -> SharingKeys {
        let publicKey = try publicKey.rsaPemString()
        let encryptedPrivateKey = try privateKey
            .rsaPemString()
            .data(using: .utf8)?
            .encrypt(using: privateKeyCryptoEngine)
            .base64EncodedString()

        guard let encryptedPrivateKey = encryptedPrivateKey else {
            throw SharingKeysError.cannotGenerateSharingKeys
        }

        return SharingKeys(publicKey: publicKey, encryptedPrivateKey: encryptedPrivateKey)
    }
}
