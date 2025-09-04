import Foundation

extension AnonymousEvent {

  public struct `Ping`: Encodable, AnonymousEventProtocol {
    public static let isPriority = false
    public init() {

    }
    public let name = "ping"
  }
}
