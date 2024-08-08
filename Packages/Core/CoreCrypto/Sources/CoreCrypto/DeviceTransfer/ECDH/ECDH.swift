import CryptoKit
import DashTypes
import Foundation

public struct ECDH {

  public typealias PrivateKey = Curve25519.KeyAgreement.PrivateKey
  public typealias PublicKey = Curve25519.KeyAgreement.PublicKey

  public let privateKey: PrivateKey
  public let publicKey: PublicKey

  public init(privateKey: PrivateKey = PrivateKey()) {
    self.privateKey = privateKey
    self.publicKey = privateKey.publicKey
  }
}

extension ECDH: ECDHProtocol {
  public var publicKeyString: DashTypes.Base64EncodedString {
    publicKey.base64EncodedString()
  }

  public func symmetricKey(withPublicKey publicKeyData: Data, base64EncodedSalt salt: String) throws
    -> Data
  {
    let symmetricKey = try privateKey.symmetricKey(
      withPublicKey: publicKeyData, base64EncodedSalt: salt)
    return symmetricKey.withUnsafeBytes {
      return Data(Array($0))
    }
  }
}
