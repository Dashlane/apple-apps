import Foundation

extension UserEvent {

  public struct `AuthenticatorLaunch`: Encodable, UserEventProtocol {
    public static let isPriority = true
    public init(`hasPasswordManagerInstalled`: Bool, `isFirstLaunch`: Bool) {
      self.hasPasswordManagerInstalled = hasPasswordManagerInstalled
      self.isFirstLaunch = isFirstLaunch
    }
    public let hasPasswordManagerInstalled: Bool
    public let isFirstLaunch: Bool
    public let name = "authenticator_launch"
  }
}
