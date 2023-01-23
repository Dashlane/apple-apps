import Foundation

extension UserEvent {

public struct `AutofillClick`: Encodable, UserEventProtocol {
public static let isPriority = false
public init(`autofillButton`: Definition.AutofillButton) {
self.autofillButton = autofillButton
}
public let autofillButton: Definition.AutofillButton
public let name = "autofill_click"
}
}
