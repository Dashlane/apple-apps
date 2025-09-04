import Foundation

extension AnonymousEvent {

  public struct `OtherAuthenticatorsInstalledReport`: Encodable, AnonymousEventProtocol {
    public static let isPriority = false
    public init(`otherAuthenticatorList`: [Definition.AuthenticatorNames]? = nil) {
      self.otherAuthenticatorList = otherAuthenticatorList
    }
    public let name = "other_authenticators_installed_report"
    public let otherAuthenticatorList: [Definition.AuthenticatorNames]?
  }
}
