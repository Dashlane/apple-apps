import AuthenticationServices
import Foundation

public struct PasskeyAssertionRequest {
  public let relyingPartyID: String
  public let clientDataHash: Data
  public let allowedCredentials: [Data]

  public init(
    relyingPartyID: String,
    clientDataHash: Data,
    allowedCredentials: [Data]
  ) {
    self.relyingPartyID = relyingPartyID
    self.clientDataHash = clientDataHash
    self.allowedCredentials = allowedCredentials
  }
}

@available(iOS 17, macOS 14, *)
extension ASPasskeyCredentialRequest {
  public func makePasskeyAssertionRequest() -> PasskeyAssertionRequest {
    return PasskeyAssertionRequest(
      relyingPartyID: self.credentialIdentity.serviceIdentifier.identifier,
      clientDataHash: clientDataHash,
      allowedCredentials: [])
  }
}

@available(iOS 17, macOS 14, *)
extension ASPasskeyCredentialRequestParameters {
  public func makePasskeyAssertionRequest() -> PasskeyAssertionRequest {
    return PasskeyAssertionRequest(
      relyingPartyID: relyingPartyIdentifier,
      clientDataHash: clientDataHash,
      allowedCredentials: allowedCredentials)
  }
}
