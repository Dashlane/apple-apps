import Foundation

extension UserEvent {

  public struct `AntiphishingRedirect`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init() {

    }
    public let name = "antiphishing_redirect"
  }
}
