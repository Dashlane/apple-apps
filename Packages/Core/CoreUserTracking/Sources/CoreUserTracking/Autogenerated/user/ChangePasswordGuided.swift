import Foundation

extension UserEvent {

public struct `ChangePasswordGuided`: Encodable, UserEventProtocol {
public static let isPriority = false
public init(`flowStep`: Definition.FlowStep, `itemId`: String) {
self.flowStep = flowStep
self.itemId = itemId
}
public let flowStep: Definition.FlowStep
public let itemId: String
public let name = "change_password_guided"
}
}
