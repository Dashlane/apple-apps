import Foundation
import CorePremium
import SwiftUI
import Combine

class PurchaseViewModel: ObservableObject {
    enum State {
        case loading
        case empty
        case fetched([PurchasePlan.Kind: PlanTier])
    }

    @Published
    var state: State = .loading

    private var subcription: AnyCancellable?

    init(manager: DashlanePremiumManager, logger: PremiumStatusLogger?) {
        subcription = manager.fetchPurchasePlanGroupsForCurrentSession().map { groups in
            groups.isEmpty ? .empty : .fetched(groups)
        }
        .replaceError(with: .empty)
        .handleEvents(receiveOutput: { state in
            guard case .empty = state else {
                return
            }
            logger?.logPremium(type: LogPremiumType.yearlyPlanDisplayErrorFailToFetchData)
        })
        .assign(to: \.state, on: self)
    }

    init(initialState: State) {
        state = initialState
    }
}
