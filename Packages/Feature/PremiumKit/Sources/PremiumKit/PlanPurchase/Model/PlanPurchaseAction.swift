import CorePremium

enum PlanPurchaseAction {
    case cancel
    case displayList
    case planDetails(PlanTier)
    case buy(PurchasePlan)
    case displayTermsAndConditions
    case displayPrivacyPolicy
}
