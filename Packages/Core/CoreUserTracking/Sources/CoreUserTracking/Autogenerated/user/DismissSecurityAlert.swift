import Foundation

extension UserEvent {

  public struct `DismissSecurityAlert`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(
      `itemTypesAffected`: [Definition.ItemType], `securityAlertItemId`: String,
      `securityAlertType`: Definition.SecurityAlertType
    ) {
      self.itemTypesAffected = itemTypesAffected
      self.securityAlertItemId = securityAlertItemId
      self.securityAlertType = securityAlertType
    }
    public let itemTypesAffected: [Definition.ItemType]
    public let name = "dismiss_security_alert"
    public let securityAlertItemId: String
    public let securityAlertType: Definition.SecurityAlertType
  }
}
