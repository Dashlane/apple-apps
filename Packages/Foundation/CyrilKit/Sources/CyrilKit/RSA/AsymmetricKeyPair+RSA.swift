import Foundation

extension AsymmetricKeyPair {

  public enum KeySize: Int {
    case rsa512 = 512
    case rsa768 = 768
    case rsa1024 = 1024
    case rsa2048 = 2048
  }
  public init(keySize: KeySize = .rsa2048) throws {

    let keyPairAttr =
      [
        kSecAttrKeyType: kSecAttrKeyTypeRSA,
        kSecAttrKeySizeInBits: keySize.rawValue,
      ] as CFDictionary

    guard let privateKey = SecKeyCreateRandomKey(keyPairAttr, nil) else {
      throw KeyError.keyGenerationFailed(.private)
    }
    guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
      throw KeyError.keyGenerationFailed(.public)
    }

    self.init(
      publicKey: .init(secKey: publicKey, algorithm: .rsa),
      privateKey: .init(secKey: privateKey, algorithm: .rsa))
  }
}
