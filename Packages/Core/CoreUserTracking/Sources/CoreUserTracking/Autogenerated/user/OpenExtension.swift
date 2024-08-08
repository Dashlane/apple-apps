import Foundation

extension UserEvent {

  public struct `OpenExtension`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(`authenticationStatus`: Definition.AuthenticationStatus? = nil) {
      self.authenticationStatus = authenticationStatus
    }
    public let authenticationStatus: Definition.AuthenticationStatus?
    public let name = "open_extension"
  }
}
