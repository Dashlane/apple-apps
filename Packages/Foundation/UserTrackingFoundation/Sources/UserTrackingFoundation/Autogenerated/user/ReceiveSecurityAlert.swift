import Foundation

extension UserEvent {

  public struct `ReceiveSecurityAlert`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(
      `itemTypesAffected`: [Definition.ItemType], `nudgeType`: Definition.NudgeType? = nil,
      `securityAlertItemId`: String, `securityAlertType`: Definition.SecurityAlertType
    ) {
      self.itemTypesAffected = itemTypesAffected
      self.nudgeType = nudgeType
      self.securityAlertItemId = securityAlertItemId
      self.securityAlertType = securityAlertType
    }
    public let itemTypesAffected: [Definition.ItemType]
    public let name = "receive_security_alert"
    public let nudgeType: Definition.NudgeType?
    public let securityAlertItemId: String
    public let securityAlertType: Definition.SecurityAlertType
  }
}
