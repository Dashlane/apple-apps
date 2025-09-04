import Foundation

extension UserEvent {

  public struct `LockApp`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init() {

    }
    public let name = "lock_app"
  }
}
