import Foundation

extension UserEvent {

public struct `CallToAction`: Encodable, UserEventProtocol {
public static let isPriority = false
public init(`callToActionList`: [Definition.CallToAction]? = nil, `chosenAction`: Definition.CallToAction? = nil, `hasChosenNoAction`: Bool) {
self.callToActionList = callToActionList
self.chosenAction = chosenAction
self.hasChosenNoAction = hasChosenNoAction
}
public let callToActionList: [Definition.CallToAction]?
public let chosenAction: Definition.CallToAction?
public let hasChosenNoAction: Bool
public let name = "call_to_action"
}
}
