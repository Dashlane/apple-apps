import CorePremium

extension PaywallViewModel.Trigger {
  var orderedByPriorityPurchaseKinds: [PurchasePlan.Kind] {
    switch self {
    case .capability(let key):
      switch key {
      case .secureWiFi, .sync, .dataLeak, .securityBreach:
        return [.premium]
      default:
        return []
      }
    default:
      return []
    }
  }
}
