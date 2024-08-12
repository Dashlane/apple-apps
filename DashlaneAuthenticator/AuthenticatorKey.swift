import Foundation

enum AuthenticatorKey: String, CustomStringConvertible {
  var description: String {
    return rawValue
  }
  case isAuthenticatorFirstLaunch
  case showStandAloneOnboarding
}
