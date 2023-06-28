import Foundation

extension UserEvent {

public struct `CreateAccountRecoveryKey`: Encodable, UserEventProtocol {
public static let isPriority = false
public init(`createKeyErrorName`: Definition.CreateKeyErrorName? = nil, `flowStep`: Definition.FlowStep) {
self.createKeyErrorName = createKeyErrorName
self.flowStep = flowStep
}
public let createKeyErrorName: Definition.CreateKeyErrorName?
public let flowStep: Definition.FlowStep
public let name = "create_account_recovery_key"
}
}
