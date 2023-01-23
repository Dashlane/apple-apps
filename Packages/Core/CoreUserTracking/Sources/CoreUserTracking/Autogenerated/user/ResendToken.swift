import Foundation

extension UserEvent {

public struct `ResendToken`: Encodable, UserEventProtocol {
public static let isPriority = true
public init() {

}
public let name = "resend_token"
}
}
