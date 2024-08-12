import CorePremium
import Foundation

public enum PlanPurchaseInitialViewRequest {
  case paywall(trigger: PaywallViewModel.Trigger)
  case list
  case plan(kind: PurchasePlan.Kind)
}
