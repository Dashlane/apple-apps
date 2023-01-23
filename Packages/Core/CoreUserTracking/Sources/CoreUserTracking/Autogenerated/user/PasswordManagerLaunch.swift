import Foundation

extension UserEvent {

public struct `PasswordManagerLaunch`: Encodable, UserEventProtocol {
public static let isPriority = false
public init(`authenticatorOtpCodesCount`: Int, `hasAuthenticatorInstalled`: Bool, `isFirstLaunch`: Bool) {
self.authenticatorOtpCodesCount = authenticatorOtpCodesCount
self.hasAuthenticatorInstalled = hasAuthenticatorInstalled
self.isFirstLaunch = isFirstLaunch
}
public let authenticatorOtpCodesCount: Int
public let hasAuthenticatorInstalled: Bool
public let isFirstLaunch: Bool
public let name = "password_manager_launch"
}
}
