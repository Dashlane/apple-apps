import Foundation

extension UserEvent {

  public struct `Click`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(`button`: Definition.Button, `clickOrigin`: Definition.ClickOrigin? = nil) {
      self.button = button
      self.clickOrigin = clickOrigin
    }
    public let button: Definition.Button
    public let clickOrigin: Definition.ClickOrigin?
    public let name = "click"
  }
}
