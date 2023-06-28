import Foundation
import Sodium

public struct NitroSecureTunnelCrypto {
    let sodium = Sodium()
    let keyPair: any KeyPairProtocol

    public var publicKey: String {
        let hexes = keyPair.publicKey.map { String(format: "%02X", $0) }
        return hexes.joined(separator: "")
    }

    var privateKey: String {
        keyPair.secretKey.utf8String!
    }

    public init() throws {
        guard let keyPair = sodium.keyExchange.keyPair() else {
            throw NitroCryptoError.couldNotGenerateKeyPair
        }
        self.keyPair = keyPair
    }

    public func createSecureTunnel(with userData: AttestationDocument.UserData) throws -> NitroSecureTunnel {
        guard let publicKeyData = Data(base64Encoded: userData.publicKey),
              let headerData = Data(base64Encoded: userData.header) else {
            throw NitroCryptoError.invalidUserData
        }
        let serverPub = KeyExchange.PublicKey(publicKeyData.bytes)
        guard let sessionKeys = sodium.keyExchange.sessionKeyPair(publicKey: keyPair.publicKey, secretKey: keyPair.secretKey, otherPublicKey: serverPub, side: .CLIENT) else {
            throw NitroCryptoError.couldNotGenerateSessionKeys
        }
        guard let pushStream = sodium.secretStream.xchacha20poly1305.initPush(secretKey: sessionKeys.rx),
              let pullstream = sodium.secretStream.xchacha20poly1305.initPull(secretKey: sessionKeys.tx, header: SecretStream.XChaCha20Poly1305.Header(headerData.bytes)) else {
            throw NitroCryptoError.couldNotCreateSecretStream
        }
        return NitroSecureTunnel(pushStream: pushStream, pullStream: pullstream)
    }
}

enum NitroCryptoError: Error {
    case couldNotGenerateKeyPair
    case couldNotGenerateSessionKeys
    case couldNotCreateSecretStream
    case couldNotEncrypt
    case couldNotDecrypt
    case invalidUserData
}
