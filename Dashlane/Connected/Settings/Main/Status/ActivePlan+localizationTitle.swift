import CorePremium
import Foundation

extension ActivePlan {
  var localizedTitle: String {
    switch self {
    case .legacy, .free:
      return L10n.Localizable.ActivePlan.freeTitle

    case .essentials:
      return L10n.Localizable.ActivePlan.essentialsTitle

    case .advanced:
      return L10n.Localizable.ActivePlan.advancedTitle

    case .trial:
      return L10n.Localizable.ActivePlan.trialTitle

    case .premium:
      return L10n.Localizable.ActivePlan.premiumTitle

    case .premiumPlus:
      return L10n.Localizable.ActivePlan.premiumPlusTitle

    case .premiumFamily:
      return L10n.Localizable.ActivePlan.familyTitle

    case .premiumPlusFamily:
      return L10n.Localizable.ActivePlan.familyPlusTitle

    }
  }
}
