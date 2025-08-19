import Foundation

extension UserEvent {

  public struct `RestorePassword`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(`itemId`: String) {
      self.itemId = itemId
    }
    public let itemId: String
    public let name = "restore_password"
  }
}
