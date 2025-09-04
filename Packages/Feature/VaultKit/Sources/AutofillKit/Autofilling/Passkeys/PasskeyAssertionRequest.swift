import AuthenticationServices
import Foundation

public protocol PasskeyAssertionRequest {
  var relyingPartyIdentifier: String { get }
  var clientDataHash: Data { get }
  var allowedCredentials: [Data] { get }

  var userVerificationPreference: ASAuthorizationPublicKeyCredentialUserVerificationPreference {
    get
  }
  var serviceIdentifier: ASCredentialServiceIdentifier { get }
}

extension ASPasskeyCredentialRequest: PasskeyAssertionRequest {

  public var relyingPartyIdentifier: String {
    guard let identity = self.credentialIdentity as? ASPasskeyCredentialIdentity else {
      return self.credentialIdentity.serviceIdentifier.identifier
    }
    return identity.relyingPartyIdentifier
  }

  public var serviceIdentifier: ASCredentialServiceIdentifier {
    self.credentialIdentity.serviceIdentifier
  }

  public var allowedCredentials: [Data] {
    []
  }
}

extension ASPasskeyCredentialRequestParameters: PasskeyAssertionRequest {
  public var serviceIdentifier: ASCredentialServiceIdentifier {
    ASCredentialServiceIdentifier(identifier: self.relyingPartyIdentifier, type: .domain)
  }
}

public struct PasskeyAssertionRequestMock: PasskeyAssertionRequest {
  public var userVerificationPreference:
    ASAuthorizationPublicKeyCredentialUserVerificationPreference = .required
  public var relyingPartyIdentifier: String
  public var clientDataHash: Data
  public var allowedCredentials: [Data]
  public var serviceIdentifier: ASCredentialServiceIdentifier {
    ASCredentialServiceIdentifier(identifier: self.relyingPartyIdentifier, type: .domain)
  }

  public init(
    relyingPartyIdentifier: String = "site.com", clientDataHash: Data = .init(),
    allowedCredentials: [Data] = []
  ) {
    self.relyingPartyIdentifier = relyingPartyIdentifier
    self.clientDataHash = clientDataHash
    self.allowedCredentials = allowedCredentials
  }
}

extension PasskeyAssertionRequest where Self == PasskeyAssertionRequestMock {
  public static var mock: Self {
    .init()
  }
}
