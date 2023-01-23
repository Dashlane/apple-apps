import Foundation

extension UserEvent {

public struct `AuthenticatorRemoveOtpCode`: Encodable, UserEventProtocol {
public static let isPriority = false
public init() {

}
public let name = "authenticator_remove_otp_code"
}
}
