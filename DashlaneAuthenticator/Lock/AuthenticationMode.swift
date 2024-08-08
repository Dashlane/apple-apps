import CoreKeychain
import Foundation
import LoginKit
import SwiftTreats

enum AuthenticationMode: Identifiable {
  case biometry(Biometry)
  case pincode(SecureLockMode.PinCodeLock)
  case biometryAndPincode(lock: SecureLockMode.PinCodeLock, biometry: Biometry)
  var id: String {
    switch self {
    case .biometry:
      return "biometry"
    case .pincode:
      return "pincode"
    case .biometryAndPincode:
      return "pincodeAndBiometry"
    }
  }
}

extension AuthenticationMode {
  var lockLabel: String {
    switch self {
    case .biometry(let type):
      return L10n.Localizable.passwordappOnboardingSubtitle(type.displayableName)
    case .pincode:
      return L10n.Localizable.passwordappOnboardingSubtitlePin
    case let .biometryAndPincode(_, type):
      return L10n.Localizable.passwordappOnboardingFallbackPinSubtitle(type.displayableName)
    }
  }

  var displayName: String {
    switch self {
    case .biometry(let type):
      return type.displayableName
    case .pincode:
      return "PIN"
    case let .biometryAndPincode(_, type):
      return type.displayableName
    }
  }
}

extension SecureLockMode {
  var authenticationMode: AuthenticationMode? {
    switch self {
    case .biometry(let value):
      return .biometry(value)
    case let .pincode(lock):
      return .pincode(lock)
    case let .biometryAndPincode(biometry, lock):
      return .biometryAndPincode(lock: lock, biometry: biometry)
    default:
      return nil
    }
  }
}
