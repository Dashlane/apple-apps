import Foundation

extension UserEvent {

  public struct `SharingSelect`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(`optionType`: Definition.OptionType) {
      self.optionType = optionType
    }
    public let name = "sharing_select"
    public let optionType: Definition.OptionType
  }
}
