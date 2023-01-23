import Foundation

extension UserEvent {

public struct `AskAuthentication`: Encodable, UserEventProtocol {
public static let isPriority = true
public init(`mode`: Definition.Mode, `reason`: Definition.Reason, `verificationMode`: Definition.VerificationMode? = nil) {
self.mode = mode
self.reason = reason
self.verificationMode = verificationMode
}
public let mode: Definition.Mode
public let name = "ask_authentication"
public let reason: Definition.Reason
public let verificationMode: Definition.VerificationMode?
}
}
