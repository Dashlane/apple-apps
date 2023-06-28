import Foundation

extension AnonymousEvent {

public struct `MasterPasswordHealthReport`: Encodable, AnonymousEventProtocol {
public static let isPriority = false
public init(`isLeaked`: Bool? = nil, `isWeak`: Bool? = nil) {
self.isLeaked = isLeaked
self.isWeak = isWeak
}
public let isLeaked: Bool?
public let isWeak: Bool?
public let name = "master_password_health_report"
}
}
