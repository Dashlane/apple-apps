import Foundation

extension AnonymousEvent {

  public struct `AuthenticateWithPasskey`: Encodable, AnonymousEventProtocol {
    public static let isPriority = false
    public init(
      `authenticationMediationType`: Definition.AuthenticationMediationType? = nil,
      `authenticatorUserVerification`: Definition.AuthenticatorUserVerification? = nil,
      `domain`: Definition.Domain, `hasCredentialsAllowed`: Bool? = nil,
      `isAuthenticatedWithDashlane`: Bool? = nil, `msToCompleteAuthentication`: Int? = nil,
      `msToCompleteAuthenticationTimeout`: Int? = nil,
      `passkeyAuthenticationErrorType`: Definition.PasskeyAuthenticationErrorType? = nil,
      `passkeyAuthenticationStatus`: Definition.CeremonyStatus,
      `passkeyType`: Definition.PasskeyType? = nil,
      `webauthnExtensionSupportedList`: [Definition.WebauthnExtensionId]? = nil
    ) {
      self.authenticationMediationType = authenticationMediationType
      self.authenticatorUserVerification = authenticatorUserVerification
      self.domain = domain
      self.hasCredentialsAllowed = hasCredentialsAllowed
      self.isAuthenticatedWithDashlane = isAuthenticatedWithDashlane
      self.msToCompleteAuthentication = msToCompleteAuthentication
      self.msToCompleteAuthenticationTimeout = msToCompleteAuthenticationTimeout
      self.passkeyAuthenticationErrorType = passkeyAuthenticationErrorType
      self.passkeyAuthenticationStatus = passkeyAuthenticationStatus
      self.passkeyType = passkeyType
      self.webauthnExtensionSupportedList = webauthnExtensionSupportedList
    }
    public let authenticationMediationType: Definition.AuthenticationMediationType?
    public let authenticatorUserVerification: Definition.AuthenticatorUserVerification?
    public let domain: Definition.Domain
    public let hasCredentialsAllowed: Bool?
    public let isAuthenticatedWithDashlane: Bool?
    public let msToCompleteAuthentication: Int?
    public let msToCompleteAuthenticationTimeout: Int?
    public let name = "authenticate_with_passkey"
    public let passkeyAuthenticationErrorType: Definition.PasskeyAuthenticationErrorType?
    public let passkeyAuthenticationStatus: Definition.CeremonyStatus
    public let passkeyType: Definition.PasskeyType?
    public let webauthnExtensionSupportedList: [Definition.WebauthnExtensionId]?
  }
}
