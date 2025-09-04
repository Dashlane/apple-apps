import CorePremium

extension CapabilityKey {
  var orderedByPriorityPurchaseKinds: [PurchasePlan.Kind] {
    switch self {
    case .secureWiFi, .sync, .dataLeak, .securityBreach:
      return [.premium]
    default:
      return []
    }
  }
}
