import CorePremium
import Foundation

public enum PlanPurchaseInitialViewRequest {
  public enum Trigger {
    case capability(key: CapabilityKey)
    case frozenAccount
  }

  case paywall(trigger: Trigger)
  case list
  case plan(kind: PurchasePlan.Kind)
}
