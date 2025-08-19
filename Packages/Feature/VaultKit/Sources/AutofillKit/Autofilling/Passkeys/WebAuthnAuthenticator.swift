import AuthenticationServices
import CorePersonalData

protocol WebAuthnAuthenticator {
  associatedtype Key
  func register(for request: ASPasskeyCredentialRequest) async throws -> RegistrationOutput
  func assert(_ request: PasskeyAssertionRequest, using passkey: Passkey, key: Key) async throws
    -> ASPasskeyAssertionCredential
}

struct RegistrationOutput {
  let registrationCredential: ASPasskeyRegistrationCredential
  let createdPasskey: Passkey
  let publicKey: [UInt8]
}
