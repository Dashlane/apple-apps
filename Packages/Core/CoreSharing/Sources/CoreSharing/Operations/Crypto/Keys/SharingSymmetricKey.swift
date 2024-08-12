import CyrilKit
import DashTypes
import Foundation

struct SharingSymmetricKey<Entity>: Equatable {
  let raw: SymmetricKey
}

extension SharingGroupMember {
  static func encrypt(
    _ groupKey: SharingSymmetricKey<Self.Group>, with publicKey: SharingPublicKey<Self.Target>,
    cryptoProvider: SharingCryptoProvider
  ) throws -> String {
    return try cryptoProvider.encrypter(using: publicKey.raw)
      .encrypt(groupKey.raw)
      .base64EncodedString()
  }

  func groupKey(
    using privateKey: SharingPrivateKey<Self.Target>, cryptoProvider: SharingCryptoProvider
  ) throws -> SharingSymmetricKey<Self.Group> {
    guard let keyBase64 = encryptedGroupKey,
      !keyBase64.isEmpty,
      let encryptedKey = Data(base64Encoded: keyBase64)
    else {
      throw SharingGroupError.missingKey(.groupKey)
    }
    let decrypter = cryptoProvider.decrypter(using: privateKey.raw)
    let key = try decrypter.decrypt(encryptedKey)

    return .init(raw: key)
  }
}

extension ItemKeyPair {
  func key(using key: SharingSymmetricKey<ItemGroup>, cryptoProvider: SharingCryptoProvider) throws
    -> SharingSymmetricKey<ItemKeyPair>
  {
    guard !encryptedKey.isEmpty,
      let encryptedKey = Data(base64Encoded: encryptedKey)
    else {
      throw SharingGroupError.missingKey(.itemKey)
    }

    let key = try encryptedKey.decrypt(using: cryptoProvider.cryptoEngine(using: key.raw))

    return SharingSymmetricKey(raw: key)
  }
}

extension SharingSymmetricKey<ItemKeyPair> {
  func encrypt(_ key: SharingSymmetricKey<ItemGroup>, cryptoProvider: SharingCryptoProvider) throws
    -> String
  {
    let engine = try cryptoProvider.cryptoEngine(using: key.raw)

    return try self.raw.encrypt(using: engine).base64EncodedString()
  }
}

extension ItemContentCache {
  func content(using key: SharingSymmetricKey<ItemKeyPair>, cryptoProvider: SharingCryptoProvider)
    throws -> SymmetricKey
  {
    guard !encryptedContent.isEmpty,
      let encryptedContent = Data(base64Encoded: encryptedContent)
    else {
      throw SharingGroupError.missingItemContent
    }

    let engine = try cryptoProvider.cryptoEngine(using: key.raw)

    return try encryptedContent.decrypt(using: engine)
  }
}

extension SharingItemUpload {
  func encryptedContent(
    using key: SharingSymmetricKey<ItemKeyPair>, cryptoProvider: SharingCryptoProvider
  ) throws -> String {
    let engine = try cryptoProvider.cryptoEngine(using: key.raw)

    return try transactionContent.encrypt(using: engine).base64EncodedString()
  }
}

extension SharingCreateContent {
  func encryptedContent(
    using key: SharingSymmetricKey<ItemKeyPair>, cryptoProvider: SharingCryptoProvider
  ) throws -> String {
    let engine = try cryptoProvider.cryptoEngine(using: key.raw)

    return try transactionContent.encrypt(using: engine).base64EncodedString()
  }
}
