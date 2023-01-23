import Foundation

extension UserEvent {

public struct `Click`: Encodable, UserEventProtocol {
public static let isPriority = false
public init(`button`: Definition.Button) {
self.button = button
}
public let button: Definition.Button
public let name = "click"
}
}
