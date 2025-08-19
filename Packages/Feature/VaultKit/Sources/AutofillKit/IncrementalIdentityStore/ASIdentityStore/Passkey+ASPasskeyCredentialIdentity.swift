import AuthenticationServices
import Combine
import CorePersonalData
import Foundation

extension ASPasskeyCredentialIdentity {
  convenience init?(_ passkey: Passkey, rank: Int) {
    guard let decodedCredentialId = Data(base64URLEncoded: passkey.credentialId),
      let decodedUserHandle = Data(base64URLEncoded: passkey.userHandle)
    else {
      return nil
    }
    self.init(
      relyingPartyIdentifier: passkey.relyingPartyId.rawValue,
      userName: passkey.userDisplayName,
      credentialID: decodedCredentialId,
      userHandle: decodedUserHandle,
      recordIdentifier: passkey.id.rawValue)
    self.rank = rank
  }
}
