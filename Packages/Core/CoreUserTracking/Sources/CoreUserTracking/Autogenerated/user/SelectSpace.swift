import Foundation

extension UserEvent {

public struct `SelectSpace`: Encodable, UserEventProtocol {
public static let isPriority = false
public init(`space`: Definition.Space) {
self.space = space
}
public let name = "select_space"
public let space: Definition.Space
}
}
