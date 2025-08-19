import Foundation

extension AnonymousEvent {

  public struct `ChangePasswordGuided`: Encodable, AnonymousEventProtocol {
    public static let isPriority = false
    public init(`domain`: Definition.Domain, `flowStep`: Definition.FlowStep) {
      self.domain = domain
      self.flowStep = flowStep
    }
    public let domain: Definition.Domain
    public let flowStep: Definition.FlowStep
    public let name = "change_password_guided"
  }
}
