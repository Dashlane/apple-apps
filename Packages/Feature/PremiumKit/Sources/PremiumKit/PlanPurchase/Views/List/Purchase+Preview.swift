#if DEBUG
  import Foundation
  import CorePremium
  import DashlaneAPI

  enum PlanPreviewUtilities {
    static func plan(kind: PurchasePlan.Kind, duration: PaymentsAccessibleStoreOffersDuration)
      -> PurchasePlan
    {
      return PurchasePlan(
        subscription: .init(id: "id", price: 4.99, purchaseAction: { _ in fatalError() }),
        offer: PaymentsAccessibleStoreOffers(
          planName: "",
          duration: duration,
          enabled: true
        ),
        kind: kind,
        capabilities: PaymentsAccessibleStoreOffersCapabilities(),
        isCurrentSubscription: false
      )
    }

    static func planTier(kind: PurchasePlan.Kind) -> PlanTier {
      return PlanTier(
        plans: [plan(kind: kind, duration: .monthly), plan(kind: kind, duration: .yearly)],
        capabilities: PaymentsAccessibleStoreOffersCapabilities()
      )
    }
  }
#endif
