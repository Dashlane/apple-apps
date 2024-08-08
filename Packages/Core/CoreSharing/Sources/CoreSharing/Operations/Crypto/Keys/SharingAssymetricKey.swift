import CyrilKit
import DashTypes
import Foundation

public struct SharingPrivateKey<Entity> {
  public let raw: PrivateKey
}

public struct SharingPublicKey<Entity> {
  public let raw: PublicKey
}

public struct SharingAsymmetricKey<Entity> {
  public let privateKey: SharingPrivateKey<Entity>
  public let publicKey: SharingPublicKey<Entity>

  public init(asymmetricKey: AsymmetricKeyPair) {
    privateKey = .init(raw: asymmetricKey.privateKey)
    publicKey = .init(raw: asymmetricKey.publicKey)
  }
}

protocol AsymmetricKeyProvider {
  associatedtype Group: SharingGroup
  var publicKey: String { get }
  var encryptedPrivateKey: String { get }
}

extension UserGroupInfo: AsymmetricKeyProvider {
  typealias Group = UserGroup
}
extension CollectionInfo: AsymmetricKeyProvider {
  typealias Group = SharingCollection
}

extension SharingGroup where Info: AsymmetricKeyProvider, Info.Group == Self {
  func publicKey(using cryptoProvider: SharingCryptoProvider) throws -> SharingPublicKey<Self> {
    return try info.publicKey(using: cryptoProvider)
  }
}

extension AsymmetricKeyProvider {
  func publicKey(using cryptoProvider: SharingCryptoProvider) throws -> SharingPublicKey<Self.Group>
  {
    let key = try cryptoProvider.publicKey(fromPemString: publicKey)

    return .init(raw: key)
  }
}

extension SharingCryptoProvider {
  func userPublicKey(fromPemString pem: String) throws -> SharingPublicKey<UserId> {
    let key = try publicKey(fromPemString: pem)
    return .init(raw: key)
  }
}

extension SharingGroup where Info: AsymmetricKeyProvider, Info.Group == Self {
  static func encrypt(
    _ privateKey: SharingPrivateKey<Self>, with groupKey: SharingSymmetricKey<Self>,
    cryptoProvider: SharingCryptoProvider
  ) throws -> String {

    guard
      let pem = try cryptoProvider.pemString(for: privateKey.raw)
        .data(using: .utf8)
    else {
      throw SharingGroupError.unknown
    }

    return try pem.encrypt(using: cryptoProvider.cryptoEngine(using: groupKey.raw))
      .base64EncodedString()
  }

  func privateKey(using key: SharingSymmetricKey<Self>, cryptoProvider: SharingCryptoProvider)
    throws -> SharingPrivateKey<Self>
  {
    return try self.info.privateKey(using: key, cryptoProvider: cryptoProvider)
  }
}

extension AsymmetricKeyProvider {
  func privateKey(using key: SharingSymmetricKey<Group>, cryptoProvider: SharingCryptoProvider)
    throws -> SharingPrivateKey<Group>
  {

    let privatePemString = try privateKey(using: cryptoProvider.cryptoEngine(using: key.raw))
    let privateKey = try cryptoProvider.privateKey(fromPemString: privatePemString)

    return .init(raw: privateKey)
  }
}

extension AsymmetricKeyProvider {
  fileprivate func privateKey(using engine: CryptoEngine) throws -> String {
    guard let data = Data(base64Encoded: encryptedPrivateKey) else {
      throw SharingGroupError.missingKey(.privateKey)
    }

    let decryptedData = try data.decrypt(using: engine)
    guard let pemString = String(data: decryptedData, encoding: .utf8) else {
      throw SharingGroupError.unknown
    }

    return pemString
  }
}
