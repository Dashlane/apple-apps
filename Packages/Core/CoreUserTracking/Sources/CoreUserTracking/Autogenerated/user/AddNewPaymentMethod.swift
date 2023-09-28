import Foundation

extension UserEvent {

public struct `AddNewPaymentMethod`: Encodable, UserEventProtocol {
public static let isPriority = false
public init(`flowStep`: Definition.FlowStep) {
self.flowStep = flowStep
}
public let flowStep: Definition.FlowStep
public let name = "add_new_payment_method"
}
}
