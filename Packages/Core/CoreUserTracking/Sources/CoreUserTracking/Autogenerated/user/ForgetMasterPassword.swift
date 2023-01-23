import Foundation

extension UserEvent {

public struct `ForgetMasterPassword`: Encodable, UserEventProtocol {
public static let isPriority = true
public init(`hasBiometricReset`: Bool, `hasTeamAccountRecovery`: Bool) {
self.hasBiometricReset = hasBiometricReset
self.hasTeamAccountRecovery = hasTeamAccountRecovery
}
public let hasBiometricReset: Bool
public let hasTeamAccountRecovery: Bool
public let name = "forget_master_password"
}
}
