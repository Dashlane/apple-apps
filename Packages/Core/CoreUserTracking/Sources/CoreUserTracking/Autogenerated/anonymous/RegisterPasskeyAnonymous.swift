import Foundation

extension AnonymousEvent {

  public struct `RegisterPasskey`: Encodable, AnonymousEventProtocol {
    public static let isPriority = false
    public init(
      `algorithmsSupportedList`: [Definition.AlgorithmsSupported]? = nil,
      `authenticatorAttachment`: Definition.AuthenticatorAttachment? = nil,
      `authenticatorResidentKey`: Definition.AuthenticatorResidentKey? = nil,
      `authenticatorUserVerification`: Definition.AuthenticatorUserVerification? = nil,
      `domain`: Definition.Domain, `isRegisteredWithDashlane`: Bool? = nil,
      `msToCompleteRegistration`: Int? = nil, `msToCompleteRegistrationTimeout`: Int? = nil,
      `passkeyRegistrationErrorType`: Definition.PasskeyRegistrationErrorType? = nil,
      `passkeyRegistrationStatus`: Definition.CeremonyStatus,
      `webauthnExtensionSupportedList`: [Definition.WebauthnExtensionId]? = nil
    ) {
      self.algorithmsSupportedList = algorithmsSupportedList
      self.authenticatorAttachment = authenticatorAttachment
      self.authenticatorResidentKey = authenticatorResidentKey
      self.authenticatorUserVerification = authenticatorUserVerification
      self.domain = domain
      self.isRegisteredWithDashlane = isRegisteredWithDashlane
      self.msToCompleteRegistration = msToCompleteRegistration
      self.msToCompleteRegistrationTimeout = msToCompleteRegistrationTimeout
      self.passkeyRegistrationErrorType = passkeyRegistrationErrorType
      self.passkeyRegistrationStatus = passkeyRegistrationStatus
      self.webauthnExtensionSupportedList = webauthnExtensionSupportedList
    }
    public let algorithmsSupportedList: [Definition.AlgorithmsSupported]?
    public let authenticatorAttachment: Definition.AuthenticatorAttachment?
    public let authenticatorResidentKey: Definition.AuthenticatorResidentKey?
    public let authenticatorUserVerification: Definition.AuthenticatorUserVerification?
    public let domain: Definition.Domain
    public let isRegisteredWithDashlane: Bool?
    public let msToCompleteRegistration: Int?
    public let msToCompleteRegistrationTimeout: Int?
    public let name = "register_passkey"
    public let passkeyRegistrationErrorType: Definition.PasskeyRegistrationErrorType?
    public let passkeyRegistrationStatus: Definition.CeremonyStatus
    public let webauthnExtensionSupportedList: [Definition.WebauthnExtensionId]?
  }
}
