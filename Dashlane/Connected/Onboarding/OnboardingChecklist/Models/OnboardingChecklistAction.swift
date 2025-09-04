import Foundation
import SwiftUILottie

enum OnboardingChecklistAction: String, Identifiable {
  var id: String {
    return title
  }

  case addFirstPasswordsManually
  case activateAutofill
  case mobileToDesktop

  var title: String {
    switch self {
    case .addFirstPasswordsManually:
      return L10n.Localizable.onboardingChecklistV2ActionTitleAddAccounts
    case .activateAutofill:
      return L10n.Localizable.onboardingChecklistV2ActionTitleActivateAutofill
    case .mobileToDesktop:
      return L10n.Localizable.onboardingChecklistV2ActionTitleM2D
    }
  }

  var caption: String {
    switch self {
    case .addFirstPasswordsManually:
      return L10n.Localizable.onboardingChecklistV2ActionCaptionAddAccounts
    case .activateAutofill:
      return L10n.Localizable.onboardingChecklistV2ActionCaptionActivateAutofill
    case .mobileToDesktop:
      return L10n.Localizable.onboardingChecklistV2ActionCaptionM2D
    }
  }

  var actionText: String {
    switch self {
    case .addFirstPasswordsManually:
      return L10n.Localizable.onboardingChecklistV2ActionButtonAddAccounts
    case .activateAutofill:
      return L10n.Localizable.onboardingChecklistV2ActionButtonActivateAutofill
    case .mobileToDesktop:
      return L10n.Localizable.onboardingChecklistV2ActionButtonM2D
    }
  }

  var index: Int {
    switch self {
    case .addFirstPasswordsManually:
      return 1
    case .activateAutofill:
      return 2
    case .mobileToDesktop:
      return 3
    }
  }

  var animationAsset: LottieAsset {
    switch self {
    case .addFirstPasswordsManually:
      return .onboardingVault
    case .activateAutofill:
      return .onboardingAutofill
    case .mobileToDesktop:
      return .onboardingM2d
    }
  }
}
