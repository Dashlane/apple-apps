import Foundation

public protocol ECDHProtocol: Sendable {
  var publicKeyString: Base64EncodedString { get }
  func symmetricKey(withPublicKey publicKeyData: Data, base64EncodedSalt salt: String) throws
    -> Data
}

public struct ECDHMock: ECDHProtocol {
  public let publicKeyString: Base64EncodedString
  let symmetricKey: String

  init(publicKey: Base64EncodedString, symmetricKey: String) {
    self.publicKeyString = publicKey
    self.symmetricKey = symmetricKey
  }

  public func symmetricKey(withPublicKey publicKeyData: Data, base64EncodedSalt salt: String) throws
    -> Data
  {
    Data()
  }
}

extension ECDHProtocol where Self == ECDHMock {
  public static func mock(
    publicKey: Base64EncodedString = "publicKey", symmetricKey: String = "symmetricKey"
  ) -> ECDHMock {
    ECDHMock(publicKey: publicKey, symmetricKey: symmetricKey)
  }
}
