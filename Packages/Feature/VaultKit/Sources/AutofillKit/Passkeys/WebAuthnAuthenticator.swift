import Algorithms
import AuthenticationServices
import CorePersonalData
import CorePremium
import CryptoKit
import CyrilKit
import DashTypes
import Foundation
import WebAuthn

@available(iOS 17, macOS 14, *)
public struct WebAuthnAuthenticator {

  let hasUserBeenVerified: Bool
  let database: ApplicationDatabase
  let userSpacesService: UserSpacesService
  let autofillService: AutofillService

  public init(
    hasUserBeenVerified: Bool,
    database: ApplicationDatabase,
    userSpacesService: UserSpacesService,
    autofillService: AutofillService
  ) {
    self.hasUserBeenVerified = hasUserBeenVerified
    self.database = database
    self.userSpacesService = userSpacesService
    self.autofillService = autofillService
  }
}

@available(iOS 17, macOS 14, *)
extension WebAuthnAuthenticator {

  public enum PasskeyCreationError: String, Error {
    case invalidPasskeyIdentity
  }

  public func create(_ request: ASPasskeyCredentialRequest) async throws -> (
    ASPasskeyRegistrationCredential, Passkey
  ) {
    let algorithm = request.supportedAlgorithms.firstSupportedAlgorithm()
    let key = WebAuthnEncryptionKey(algorithm: algorithm)

    guard let identity = request.credentialIdentity as? ASPasskeyCredentialIdentity else {
      throw PasskeyCreationError.invalidPasskeyIdentity
    }

    let credentialID = Data.makeRandomCredentialIdentifier()
    let relyingParty = request.credentialIdentity.serviceIdentifier.identifier
    var passkey = Passkey(
      credentialID: credentialID,
      relyingParty: relyingParty,
      userHandle: identity.userHandle,
      userName: identity.userName,
      key: key
    )

    passkey.spaceId = userSpacesService.configuration.defaultSpace(for: passkey).personalDataId
    let savedPasskey = try database.save(passkey)

    await autofillService.save(savedPasskey, oldPasskey: nil)

    let attestationObject = AttestationObject(
      authenticatorData: .init(
        relyingPartyID: relyingParty,
        attestationInformation: .init(
          credentialId: credentialID,
          applicationIdentifier: .dashlane,
          publicKey: key.privateKey.ec2PublicKey
        ),
        counter: 0,
        flags: .registration(hasUserBeenVerified: hasUserBeenVerified)
      )
    )
    let credential = ASPasskeyRegistrationCredential(
      relyingParty: relyingParty,
      clientDataHash: request.clientDataHash,
      credentialID: credentialID,
      attestationObject: attestationObject.rawAuthenticatorData
    )

    return (credential, passkey)
  }
}

@available(iOS 17, macOS 14, *)
extension WebAuthnAuthenticator {

  public enum PasskeyAssertionError: String, Error {
    case couldNotFindPasskeyForRequest
    case couldNotDecodePrivateKey
    case couldNotDecodeCredentialID
  }

  public func authenticate(
    _ request: ASPasskeyCredentialRequest
  ) throws -> (ASPasskeyAssertionCredential, Passkey) {
    let passkeys = try database.fetchAll(Passkey.self)
    guard let passkey = passkeys.first(for: request) else {
      throw PasskeyAssertionError.couldNotFindPasskeyForRequest
    }
    let passkeyRequest = request.makePasskeyAssertionRequest()
    let credential = try self.assert(passkey, for: passkeyRequest)
    return (credential, passkey)
  }

  public func assert(
    _ passkey: Passkey,
    for request: PasskeyAssertionRequest
  ) throws -> ASPasskeyAssertionCredential {
    guard let key = try WebAuthnEncryptionKey(jwk: passkey.privateKey) else {
      throw PasskeyAssertionError.couldNotDecodePrivateKey
    }
    let authenticatorData = AuthenticatorData(
      relyingPartyID: request.relyingPartyID,
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

    try database.updateLastUseDate(for: [passkey.id], origin: [.default])

    let credential = ASPasskeyAssertionCredential(
      userHandle: Data(base64URLEncoded: passkey.userHandle)!,
      relyingParty: request.relyingPartyID,
      signature: signature,
      clientDataHash: request.clientDataHash,
      authenticatorData: Data(authenticatorData),
      credentialID: decodedCredentialID
    )
    return credential
  }
}

@available(iOS 17, macOS 14, *)
extension Collection where Element == Passkey {
  func first(for request: ASPasskeyCredentialRequest) -> Passkey? {
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
