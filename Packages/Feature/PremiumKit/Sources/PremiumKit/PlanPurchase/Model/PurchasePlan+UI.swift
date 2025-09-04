import CoreLocalization
import CorePremium
import Foundation
import StoreKit

extension PurchasePlan.Kind {
  var localizedTitle: String {
    switch self {
    case .free:
      return CoreL10n.plansFreeDescription
    case .essentials:
      return CoreL10n.plansEssentialsTitle
    case .advanced:
      return CoreL10n.plansAdvancedTitle
    case .premium:
      return CoreL10n.plansPremiumTitle
    case .family:
      return CoreL10n.plansFamilyTitle
    }
  }

  var localizedDescription: String {
    switch self {
    case .free:
      return CoreL10n.planScreensFreePlanDescription
    case .essentials:
      return CoreL10n.plansEssentialsDescription
    case .advanced:
      return CoreL10n.plansAdvancedDescription
    case .premium:
      return CoreL10n.plansPremiumDescription
    case .family:
      return CoreL10n.plansFamilyDescription
    }
  }
}

extension PurchasePlan {
  var localizedTitle: String {
    kind.localizedTitle
  }

  var localizedDescription: String {
    kind.localizedDescription
  }
}

extension PlanTier {
  var localizedTitle: String {
    kind?.localizedTitle ?? ""
  }

  var localizedDescription: String {
    kind?.localizedDescription ?? ""
  }
}
