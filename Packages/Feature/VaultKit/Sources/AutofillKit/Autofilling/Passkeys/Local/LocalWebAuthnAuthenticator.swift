import Algorithms
import AuthenticationServices
import CorePersonalData
import CorePremium
import CoreTypes
import CryptoKit
import CyrilKit
import Foundation
import WebAuthn

struct LocalWebAuthnAuthenticator: WebAuthnAuthenticator {

  let hasUserBeenVerified: Bool

  public init(hasUserBeenVerified: Bool) {
    self.hasUserBeenVerified = hasUserBeenVerified
  }
}

extension LocalWebAuthnAuthenticator {

  enum PasskeyCreationError: String, Error {
    case invalidPasskeyIdentity
  }

  func register(for request: ASPasskeyCredentialRequest) async throws -> RegistrationOutput {
    let algorithm = request.supportedAlgorithms.firstSupportedAlgorithm()
    let key = WebAuthnEncryptionKey(algorithm: algorithm)

    guard let identity = request.credentialIdentity as? ASPasskeyCredentialIdentity else {
      throw PasskeyCreationError.invalidPasskeyIdentity
    }

    let credentialID = Passkey.makeCredentialId()
    let relyingParty = identity.relyingPartyIdentifier
    let passkey = Passkey(
      credentialID: credentialID,
      relyingParty: relyingParty,
      userHandle: identity.userHandle,
      userName: identity.userName,
      key: key
    )

    let authenticatorData = AuthenticatorData(
      relyingPartyID: relyingParty,
      attestationInformation: .init(
        credentialId: credentialID,
        applicationIdentifier: .dashlane,
        publicKey: key.privateKey.ec2PublicKey
      ),
      counter: 0,
      flags: .registration(hasUserBeenVerified: hasUserBeenVerified)
    )
    let attestationObject = AttestationObject(authenticatorData: authenticatorData)
    let publicKey = authenticatorData.attestedData!.publicKey

    let registration = ASPasskeyRegistrationCredential(
      relyingParty: relyingParty,
      clientDataHash: request.clientDataHash,
      credentialID: credentialID,
      attestationObject: attestationObject.rawAuthenticatorData
    )

    return RegistrationOutput(
      registrationCredential: registration,
      createdPasskey: passkey,
      publicKey: publicKey)
  }
}

extension LocalWebAuthnAuthenticator {

  enum PasskeyAssertionError: String, Error {
    case couldNotDecodePrivateKey
    case couldNotDecodeCredentialID
  }

  func assert(
    _ request: PasskeyAssertionRequest,
    using passkey: Passkey,
    key: JWK
  ) async throws -> ASPasskeyAssertionCredential {
    guard let key = try WebAuthnEncryptionKey(jwk: key) else {
      throw PasskeyAssertionError.couldNotDecodePrivateKey
    }
    let authenticatorData = AuthenticatorData(
      relyingPartyID: request.relyingPartyIdentifier,
      attestationInformation: nil,
      counter: UInt32(passkey.counter),
      flags: .assertion(hasUserBeenVerified: hasUserBeenVerified)
    )
    .byteArrayRepresentation()

    let signatureBase = Data(authenticatorData) + request.clientDataHash
    let signature = try key.signature(for: signatureBase)
    guard let decodedCredentialID = Data(base64URLEncoded: passkey.credentialId) else {
      throw PasskeyAssertionError.couldNotDecodeCredentialID
    }

    let credential = ASPasskeyAssertionCredential(
      userHandle: Data(base64URLEncoded: passkey.userHandle)!,
      relyingParty: request.relyingPartyIdentifier,
      signature: signature,
      clientDataHash: request.clientDataHash,
      authenticatorData: Data(authenticatorData),
      credentialID: decodedCredentialID
    )

    return credential
  }
}

extension Collection where Element == Passkey {
  public func first(for request: ASPasskeyCredentialRequest) -> Passkey? {
    guard let passkeyCredentialIdentity = request.credentialIdentity as? ASPasskeyCredentialIdentity
    else {
      return nil
    }
    let encodedCredentialID = passkeyCredentialIdentity.credentialID.base64URLEncoded()
    if let passkey = self.first(with: encodedCredentialID) {
      return passkey
    }
    let rpId = request.credentialIdentity.serviceIdentifier.identifier
    return self.first { $0.relyingPartyId.rawValue == rpId }
  }
}
