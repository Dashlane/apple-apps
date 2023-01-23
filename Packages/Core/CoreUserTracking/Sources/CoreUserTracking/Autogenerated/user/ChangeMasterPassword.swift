import Foundation

extension UserEvent {

public struct `ChangeMasterPassword`: Encodable, UserEventProtocol {
public static let isPriority = false
public init(`errorName`: Definition.ChangeMasterPasswordError? = nil, `flowStep`: Definition.FlowStep) {
self.errorName = errorName
self.flowStep = flowStep
}
public let errorName: Definition.ChangeMasterPasswordError?
public let flowStep: Definition.FlowStep
public let name = "change_master_password"
}
}
