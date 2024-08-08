import Foundation

extension UserEvent {

  public struct `InteractInTacMessage`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(
      `hasClickedCta`: Bool, `hasCta`: Bool, `isDiscarded`: Bool,
      `tacNotification`: Definition.TacNotification
    ) {
      self.hasClickedCta = hasClickedCta
      self.hasCta = hasCta
      self.isDiscarded = isDiscarded
      self.tacNotification = tacNotification
    }
    public let hasClickedCta: Bool
    public let hasCta: Bool
    public let isDiscarded: Bool
    public let name = "interact_in_tac_message"
    public let tacNotification: Definition.TacNotification
  }
}
