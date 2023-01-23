import Foundation
import CorePremium

public enum PlanPurchaseInitialViewRequest {
    case paywall(key: CapabilityKey)
    case list
    case plan(kind: PurchasePlan.Kind)
}
