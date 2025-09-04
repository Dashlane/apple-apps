import Foundation

extension UserEvent {

  public struct `ViewPage`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init() {

    }
    public let name = "view_page"
  }
}
