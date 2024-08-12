import Foundation

public enum AuthenticatorUserDefaultKey: String, CustomStringConvertible {
  public var description: String {
    return rawValue
  }
  case show2FAOnboarding
  case showPwdAppOnboarding
}
