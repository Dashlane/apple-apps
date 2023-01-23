import Foundation

extension UserEvent {

public struct `AuthenticatorAddOtpCode`: Encodable, UserEventProtocol {
public static let isPriority = false
public init(`otpAdditionMode`: Definition.OtpAdditionMode) {
self.otpAdditionMode = otpAdditionMode
}
public let name = "authenticator_add_otp_code"
public let otpAdditionMode: Definition.OtpAdditionMode
}
}
