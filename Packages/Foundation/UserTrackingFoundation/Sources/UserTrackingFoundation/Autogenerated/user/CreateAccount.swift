import Foundation

extension UserEvent {

  public struct `CreateAccount`: Encodable, UserEventProtocol {
    public static let isPriority = true
    public init(
      `androidMarketing`: Definition.Android? = nil, `iosMarketing`: Definition.Ios? = nil,
      `isMarketingOptIn`: Bool, `status`: Definition.AccountCreationStatus,
      `webMarketing`: Definition.WebAccountCreation? = nil
    ) {
      self.androidMarketing = androidMarketing
      self.iosMarketing = iosMarketing
      self.isMarketingOptIn = isMarketingOptIn
      self.status = status
      self.webMarketing = webMarketing
    }
    public let androidMarketing: Definition.Android?
    public let iosMarketing: Definition.Ios?
    public let isMarketingOptIn: Bool
    public let name = "create_account"
    public let status: Definition.AccountCreationStatus
    public let webMarketing: Definition.WebAccountCreation?
  }
}
