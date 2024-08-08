import Foundation
import LocalAuthentication
import SwiftTreats

enum AutofillError: Error {
  case noUserConnected(details: String)
  case ssoUserWithNoConvenientLoginMethod

  var canAuthenticateUsingBiometrics: Bool {
    let context = LAContext()
    return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
  }

  var title: String {
    switch self {
    case .noUserConnected:
      return L10n.Localizable.tachyonLoginRequiredScreenDescription
    case .ssoUserWithNoConvenientLoginMethod:
      if canAuthenticateUsingBiometrics {
        return L10n.Localizable.ssoUseBiometricsContent(Device.currentBiometryDisplayableName)
      } else {
        return L10n.Localizable.ssoUsePinCodeContent
      }
    }
  }

  var code: String {
    switch self {
    case let .noUserConnected(details):
      return details
    case .ssoUserWithNoConvenientLoginMethod:
      return "ConvenientMethod"
    }
  }

  var actionTitle: String {
    switch self {
    case .noUserConnected:
      return L10n.Localizable.tachyonLoginRequiredScreenCTA
    case .ssoUserWithNoConvenientLoginMethod:
      if canAuthenticateUsingBiometrics {
        return L10n.Localizable.tachyonConvenientLoginMethodRequiredScreenCTA
      } else {
        return L10n.Localizable.tachyonConvenientLoginMethodRequiredScreenCTA
      }
    }
  }
}
