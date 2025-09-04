import DashlaneAPI
import Foundation
import LogFoundation
import Sodium

public struct NitroSecureTunnelCreatorImpl: NitroSecureTunnelCreator {
  let sodium = Sodium()
  let keyPair: any KeyPairProtocol
  let certificate: NitroSecureTunnelCertificate

  public var publicKey: String {
    let hexes = keyPair.publicKey.map { String(format: "%02X", $0) }
    return hexes.joined(separator: "")
  }

  public init() throws {
    try self.init(certificate: .prod)
  }

  public init(certificate: NitroSecureTunnelCertificate = .prod) throws {
    guard let keyPair = sodium.keyExchange.keyPair() else {
      throw NitroCryptoError.couldNotGenerateKeyPair
    }
    self.keyPair = keyPair
    self.certificate = certificate
  }

  public func create(withRawAttestation attestation: String) throws -> any DashlaneAPI.SecureTunnel
  {
    let attestationDocument = try AttestationDocument(rawAttestation: attestation)
    try attestationDocument.verify(using: certificate)

    return try create(with: attestationDocument.userData)
  }

  func create(with userData: AttestationDocument.UserData) throws -> NitroSecureTunnel {
    guard let publicKeyData = Data(base64Encoded: userData.publicKey),
      let headerData = Data(base64Encoded: userData.header)
    else {
      throw NitroCryptoError.invalidUserData
    }
    let serverPub = KeyExchange.PublicKey(publicKeyData.bytes)
    guard
      let sessionKeys = sodium.keyExchange.sessionKeyPair(
        publicKey: keyPair.publicKey, secretKey: keyPair.secretKey, otherPublicKey: serverPub,
        side: .CLIENT)
    else {
      throw NitroCryptoError.couldNotGenerateSessionKeys
    }
    guard
      let pushStream = sodium.secretStream.xchacha20poly1305.initPush(secretKey: sessionKeys.rx),
      let pullstream = sodium.secretStream.xchacha20poly1305.initPull(
        secretKey: sessionKeys.tx, header: SecretStream.XChaCha20Poly1305.Header(headerData.bytes))
    else {
      throw NitroCryptoError.couldNotCreateSecretStream
    }
    return NitroSecureTunnel(pushStream: pushStream, pullStream: pullstream)
  }
}

@Loggable
enum NitroCryptoError: Error {
  case couldNotGenerateKeyPair
  case couldNotGenerateSessionKeys
  case couldNotCreateSecretStream
  case couldNotEncrypt
  case couldNotDecrypt
  case invalidUserData
}
