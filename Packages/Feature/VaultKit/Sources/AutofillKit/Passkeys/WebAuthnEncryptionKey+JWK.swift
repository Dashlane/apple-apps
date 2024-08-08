import CyrilKit
import Foundation
import WebAuthn

extension WebAuthnEncryptionKey {
  init?(jwk: JWK) throws {
    let privateKey: PrivateKey

    switch jwk.crv {
    case .p521:
      privateKey = try .es512(.init(jwk: jwk))
    case .p384:
      privateKey = try .es384(.init(jwk: jwk))
    case .p256:
      privateKey = try .es256(.init(jwk: jwk))
    default:
      return nil
    }

    self.init(privateKey: privateKey)
  }

  func jwk() -> JWK {
    switch privateKey {
    case let .es512(key):
      return key.jwk()
    case let .es384(key):
      return key.jwk()
    case let .es256(key):
      return key.jwk()
    }
  }
}
