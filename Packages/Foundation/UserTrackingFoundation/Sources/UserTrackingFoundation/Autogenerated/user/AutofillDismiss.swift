import Foundation

extension UserEvent {

  public struct `AutofillDismiss`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(`dismissType`: Definition.DismissType) {
      self.dismissType = dismissType
    }
    public let dismissType: Definition.DismissType
    public let name = "autofill_dismiss"
  }
}
