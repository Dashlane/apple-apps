import Foundation

extension UserEvent {

  public struct `MigrateAuthMethod`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(
      `authMethodMigrationFlowStep`: Definition.AuthMethodMigrationFlowStep,
      `errorName`: Definition.MigrateAuthMethodError? = nil,
      `originalAuthMethod`: Definition.OriginalAuthMethod? = nil
    ) {
      self.authMethodMigrationFlowStep = authMethodMigrationFlowStep
      self.errorName = errorName
      self.originalAuthMethod = originalAuthMethod
    }
    public let authMethodMigrationFlowStep: Definition.AuthMethodMigrationFlowStep
    public let errorName: Definition.MigrateAuthMethodError?
    public let name = "migrate_auth_method"
    public let originalAuthMethod: Definition.OriginalAuthMethod?
  }
}
