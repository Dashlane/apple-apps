import Foundation

extension UserEvent {

public struct `Logout`: Encodable, UserEventProtocol {
public static let isPriority = true
public init() {

}
public let name = "logout"
}
}
