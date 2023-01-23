import Foundation

extension AnonymousEvent {

public struct `AuthenticatorAddOtpCode`: Encodable, AnonymousEventProtocol {
public static let isPriority = false
public init(`authenticatorIssuerId`: String? = nil, `otpAdditionMode`: Definition.OtpAdditionMode, `otpSpecifications`: Definition.OtpSpecifications? = nil) {
self.authenticatorIssuerId = authenticatorIssuerId
self.otpAdditionMode = otpAdditionMode
self.otpSpecifications = otpSpecifications
}
public let authenticatorIssuerId: String?
public let name = "authenticator_add_otp_code"
public let otpAdditionMode: Definition.OtpAdditionMode
public let otpSpecifications: Definition.OtpSpecifications?
}
}
