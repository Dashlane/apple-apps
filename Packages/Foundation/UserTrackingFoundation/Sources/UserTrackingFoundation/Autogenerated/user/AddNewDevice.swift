import Foundation

extension UserEvent {

  public struct `AddNewDevice`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(`action`: Definition.ActionDuringTransfer) {
      self.action = action
    }
    public let action: Definition.ActionDuringTransfer
    public let name = "add_new_device"
  }
}
