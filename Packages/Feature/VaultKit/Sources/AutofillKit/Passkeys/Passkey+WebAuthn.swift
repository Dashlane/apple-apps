import CorePersonalData
import Foundation
import WebAuthn

extension Passkey {
  init(
    credentialID: Data,
    relyingParty: String,
    userHandle: Data,
    userName: String,
    key: WebAuthnEncryptionKey
  ) {
    self.init(
      title: relyingParty,
      credentialId: credentialID.base64URLEncoded(),
      relyingPartyId: relyingParty,
      relyingPartyName: relyingParty,
      userHandle: userHandle.base64URLEncoded(),
      userDisplayName: userName,
      counter: 0,
      keyAlgorithm: key.algorithm.rawValue,
      privateKey: key.jwk())
  }
}
