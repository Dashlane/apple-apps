import Foundation

extension UserEvent {

  public struct `GeneratePublicApiKey`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(`publicApiKeyStep`: Definition.PublicApiKeyStep) {
      self.publicApiKeyStep = publicApiKeyStep
    }
    public let name = "generate_public_api_key"
    public let publicApiKeyStep: Definition.PublicApiKeyStep
  }
}
