import Foundation

extension UserEvent {

public struct `Login`: Encodable, UserEventProtocol {
public static let isPriority = true
public init(`isBackupCode`: Bool? = nil, `isFirstLogin`: Bool? = nil, `mode`: Definition.Mode? = nil, `status`: Definition.Status, `verificationMode`: Definition.VerificationMode? = nil) {
self.isBackupCode = isBackupCode
self.isFirstLogin = isFirstLogin
self.mode = mode
self.status = status
self.verificationMode = verificationMode
}
public let isBackupCode: Bool?
public let isFirstLogin: Bool?
public let mode: Definition.Mode?
public let name = "login"
public let status: Definition.Status
public let verificationMode: Definition.VerificationMode?
}
}
