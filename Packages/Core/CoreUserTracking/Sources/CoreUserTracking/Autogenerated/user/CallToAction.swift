import Foundation

extension UserEvent {

  public struct `CallToAction`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(
      `callToActionList`: [Definition.CallToAction]? = nil,
      `chosenAction`: Definition.CallToAction? = nil, `hasChosenNoAction`: Bool,
      `toastName`: Definition.ToastName? = nil
    ) {
      self.callToActionList = callToActionList
      self.chosenAction = chosenAction
      self.hasChosenNoAction = hasChosenNoAction
      self.toastName = toastName
    }
    public let callToActionList: [Definition.CallToAction]?
    public let chosenAction: Definition.CallToAction?
    public let hasChosenNoAction: Bool
    public let name = "call_to_action"
    public let toastName: Definition.ToastName?
  }
}
