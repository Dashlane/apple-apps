import Foundation

extension UserEvent {

public struct `OpenReferral`: Encodable, UserEventProtocol {
public static let isPriority = false
public init() {

}
public let name = "open_referral"
}
}
