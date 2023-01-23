import Foundation

extension UserEvent {

public struct `AskUseOtherAuthentication`: Encodable, UserEventProtocol {
public static let isPriority = true
public init(`next`: Definition.Mode, `previous`: Definition.Mode) {
self.next = next
self.previous = previous
}
public let name = "ask_use_other_authentication"
public let next: Definition.Mode
public let previous: Definition.Mode
}
}
