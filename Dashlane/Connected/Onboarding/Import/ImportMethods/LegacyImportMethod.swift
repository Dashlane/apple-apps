import DesignSystem
import SwiftUI

enum LegacyImportMethod: String, Identifiable {
  case chrome
  case dash
  case keychain
  case keychainCSV
  case manual

  var id: String {
    return rawValue
  }

  var title: String {
    switch self {
    case .chrome:
      return L10n.Localizable.guidedOnboardingImportMethodChrome
    case .dash:
      return L10n.Localizable.guidedOnboardingImportMethodDash
    case .keychain:
      return L10n.Localizable.guidedOnboardingImportMethodKeychain
    case .keychainCSV:
      return L10n.Localizable.guidedOnboardingImportMethodKeychainCSV
    case .manual:
      return L10n.Localizable.guidedOnboardingImportMethodManual
    }
  }

  var image: Image {
    switch self {
    case .chrome:
      return Image.ds.googleChrome.outlined
    case .dash:
      return Image(.Onboarding.importMethodDash)
    case .keychain, .keychainCSV:
      return Image(.Onboarding.importMethodSafari)
    case .manual:
      return Image.ds.action.add.outlined
    }
  }
}
