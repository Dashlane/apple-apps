import Foundation

extension UserEvent {

public struct `AddTwoFactorAuthenticationToCredential`: Encodable, UserEventProtocol {
public static let isPriority = false
public init(`flowStep`: Definition.FlowStep, `itemId`: String? = nil, `otpAdditionError`: Definition.OtpAdditionError? = nil, `otpAdditionMode`: Definition.OtpAdditionMode, `space`: Definition.Space? = nil) {
self.flowStep = flowStep
self.itemId = itemId
self.otpAdditionError = otpAdditionError
self.otpAdditionMode = otpAdditionMode
self.space = space
}
public let flowStep: Definition.FlowStep
public let itemId: String?
public let name = "add_two_factor_authentication_to_credential"
public let otpAdditionError: Definition.OtpAdditionError?
public let otpAdditionMode: Definition.OtpAdditionMode
public let space: Definition.Space?
}
}
