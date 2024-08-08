import Foundation

extension AnonymousEvent {

  public struct `RestorePassword`: Encodable, AnonymousEventProtocol {
    public static let isPriority = false
    public init(`domain`: Definition.Domain) {
      self.domain = domain
    }
    public let domain: Definition.Domain
    public let name = "restore_password"
  }
}
