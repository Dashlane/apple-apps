import Combine
import CorePremium
import Foundation
import SwiftUI

@MainActor
class PurchaseViewModel: ObservableObject {
  enum State {
    case loading
    case empty
    case fetched([PurchasePlan.Kind: PlanTier])
  }

  @Published
  var state: State = .loading

  init(purchaseService: PurchaseService) {
    Task {
      do {
        let groups = try await purchaseService.fetchPurchasePlanGroups()
        state = groups.isEmpty ? .empty : .fetched(groups)
      } catch {
        state = .empty
      }
    }
  }

  init(initialState: State) {
    state = initialState
  }
}
