import AuthenticationServices
import CorePersonalData
import DashlaneAPI
import LogFoundation
import Logger

struct CloudWebAuthnAuthenticator: WebAuthnAuthenticator {
  enum PasskeyError: String, Error {
    case invalidPasskeyIdentity
    case invalidResponse

  }

  let client: UserSecureNitroEncryptionAPIClient.Passkeys
  let hasUserBeenVerified: Bool
  let logger: Logger
}

extension CloudWebAuthnAuthenticator {
  func register(for request: ASPasskeyCredentialRequest) async throws -> RegistrationOutput {
    do {
      guard let identity = request.credentialIdentity as? ASPasskeyCredentialIdentity else {
        throw PasskeyError.invalidPasskeyIdentity
      }

      let options = APIRegisterPasskeyRequest.Options(
        user: .init(identity: identity),
        pubKeyCredParams: request.supportedAlgorithms.map { .init(algorithm: $0) },
        rp: .init(relyingPartyIdentifier: identity.relyingPartyIdentifier),
        attestation: APIRegisterPasskeyRequest.Options.Attestation.none,
        extensions: .init(credProps: true)
      )

      let apiRequest = APIRegisterPasskeyRequest(
        clientDataHash: request.clientDataHash.base64URLEncoded(),
        origin: identity.relyingPartyIdentifier,
        options: options,
        userVerificationDone: hasUserBeenVerified)

      let repsonse = try await client.registerPasskey(request: apiRequest)

      guard
        let attestationObject = Data(
          base64URLEncoded: repsonse.credentialRegisterData.attestationObject),
        let credentialID = Data(base64URLEncoded: repsonse.credentialRegisterData.rawId),
        let publicKey = Data(base64URLEncoded: repsonse.credentialRegisterData.publicKey)?.bytes
      else {
        throw PasskeyError.invalidResponse
      }

      let cloudPasskey = Passkey.CloudPasskey(
        passkeyId: repsonse.passkeyId,
        passkeyEncryptionKey: repsonse.encryptionKey.key,
        passkeyEncryptionKeyId: repsonse.encryptionKey.uuid)
      let passkey = Passkey(
        title: identity.serviceIdentifier.identifier,
        credentialId: repsonse.credentialRegisterData.rawId,
        relyingPartyId: identity.relyingPartyIdentifier,
        relyingPartyName: identity.relyingPartyIdentifier,
        userHandle: apiRequest.options.user.id,
        userDisplayName: apiRequest.options.user.displayName,
        counter: 0,
        cloudPasskey: cloudPasskey)

      let registration = ASPasskeyRegistrationCredential(
        relyingParty: identity.relyingPartyIdentifier,
        clientDataHash: request.clientDataHash,
        credentialID: credentialID,
        attestationObject: attestationObject
      )

      return RegistrationOutput(
        registrationCredential: registration,
        createdPasskey: passkey,
        publicKey: publicKey)
    } catch let error as NitroEncryptionError {
      logger.fatal("Can't register passkey", error: error)
      throw error
    } catch {
      logger.error("Can't register passkey", error: error)
      throw error
    }
  }
}

private typealias APIRegisterPasskeyRequest = UserSecureNitroEncryptionAPIClient.Passkeys
  .RegisterPasskey.Body.Request

extension APIRegisterPasskeyRequest.Options.PubKeyCredParamsElement {
  fileprivate init(algorithm: ASCOSEAlgorithmIdentifier) {
    self.init(alg: algorithm.rawValue, type: .publicKey)
  }
}

extension APIRegisterPasskeyRequest.Options.User {
  fileprivate init(identity: ASPasskeyCredentialIdentity) {
    self.init(
      id: identity.userHandle.base64URLEncoded(), displayName: identity.userName,
      name: identity.user)
  }
}

extension APIRegisterPasskeyRequest.Options.Rp {
  fileprivate init(relyingPartyIdentifier: String) {
    self.init(name: relyingPartyIdentifier, id: relyingPartyIdentifier)
  }
}

extension CloudWebAuthnAuthenticator {

  func assert(
    _ request: PasskeyAssertionRequest,
    using passkey: Passkey,
    key cloudPasskey: Passkey.CloudPasskey
  ) async throws -> ASPasskeyAssertionCredential {
    do {

      let apiRequest = APIUsePasskeyRequest(
        clientDataHash: request.clientDataHash.base64URLEncoded(),
        origin: request.relyingPartyIdentifier,
        options: .init(
          extensions: .init(credProps: true),
          rpId: request.relyingPartyIdentifier
        ),
        userVerificationDone: hasUserBeenVerified
      )

      let response = try await client.usePasskey(
        request: apiRequest,
        passkeyId: cloudPasskey.passkeyId,
        encryptionKey: cloudPasskey.encryptionKey)

      guard let userHandleString = response.credentialGetData.response.userHandle,
        let userHandle = Data(base64URLEncoded: userHandleString),
        let signature = Data(base64URLEncoded: response.credentialGetData.response.signature),
        let clientDataHash = Data(
          base64URLEncoded: response.credentialGetData.response.clientDataHash),
        let authenticatorData = Data(
          base64URLEncoded: response.credentialGetData.response.authenticatorData),
        let credentialID = Data(base64URLEncoded: response.credentialGetData.rawId)
      else {
        throw PasskeyError.invalidResponse
      }

      return ASPasskeyAssertionCredential(
        userHandle: userHandle,
        relyingParty: request.relyingPartyIdentifier,
        signature: signature,
        clientDataHash: clientDataHash,
        authenticatorData: authenticatorData,
        credentialID: credentialID)
    } catch let error as NitroEncryptionError {
      logger.fatal("Can't assert cloud passkey \(passkey.id)", error: error)
      throw error
    } catch {
      logger.error("Can't assert cloud passkey \(passkey.id)", error: error)
      throw error
    }
  }
}

private typealias APIUsePasskeyRequest = UserSecureNitroEncryptionAPIClient.Passkeys.UsePasskey.Body
  .Request
