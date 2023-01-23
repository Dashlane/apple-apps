import Foundation

extension AnonymousEvent {

public struct `AddTwoFactorAuthenticationToCredential`: Encodable, AnonymousEventProtocol {
public static let isPriority = false
public init(`authenticatorIssuerId`: String? = nil, `domain`: Definition.Domain? = nil, `flowStep`: Definition.FlowStep, `otpAdditionError`: Definition.OtpAdditionError? = nil, `otpAdditionMode`: Definition.OtpAdditionMode, `otpSpecifications`: Definition.OtpSpecifications? = nil, `space`: Definition.Space? = nil) {
self.authenticatorIssuerId = authenticatorIssuerId
self.domain = domain
self.flowStep = flowStep
self.otpAdditionError = otpAdditionError
self.otpAdditionMode = otpAdditionMode
self.otpSpecifications = otpSpecifications
self.space = space
}
public let authenticatorIssuerId: String?
public let domain: Definition.Domain?
public let flowStep: Definition.FlowStep
public let name = "add_two_factor_authentication_to_credential"
public let otpAdditionError: Definition.OtpAdditionError?
public let otpAdditionMode: Definition.OtpAdditionMode
public let otpSpecifications: Definition.OtpSpecifications?
public let space: Definition.Space?
}
}
