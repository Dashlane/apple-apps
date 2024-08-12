import Foundation

extension UserEvent {

  public struct `UseAnotherAccount`: Encodable, UserEventProtocol {
    public static let isPriority = true
    public init() {

    }
    public let name = "use_another_account"
  }
}
