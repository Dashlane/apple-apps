import DashTypes
import DashlaneAPI
import Foundation

extension UserDeviceAPIClient.Payments {
  public func getAccessibleStoreOffers() async throws
    -> UserDeviceAPIClient.Payments.GetAccessibleStoreOffers.Response
  {
    try await getAccessibleStoreOffers(platform: .ios)
  }
}

extension UserDeviceAPIClient.Payments.GetAccessibleStoreOffers.Response {
  public func allOffers() -> [PaymentsAccessibleStoreOffers] {
    return freeOffers.offers + premiumOffers.offers + essentialsOffers.offers + familyOffers.offers
  }
}

extension UserDeviceAPIClient.Payments.GetAccessibleStoreOffers.Response {
  struct Product {
    let offers: [PaymentsAccessibleStoreOffers]
    let kind: PurchasePlan.Kind
    let capabilities: PaymentsAccessibleStoreOffersCapabilities
  }

  var products: [Product] {
    [
      .init(offers: freeOffers.offers, kind: .free, capabilities: freeOffers.capabilities),
      .init(
        offers: essentialsOffers.offers, kind: .advanced,
        capabilities: essentialsOffers.capabilities),
      .init(offers: premiumOffers.offers, kind: .premium, capabilities: premiumOffers.capabilities),
      .init(offers: familyOffers.offers, kind: .family, capabilities: familyOffers.capabilities),
    ]
  }
}
