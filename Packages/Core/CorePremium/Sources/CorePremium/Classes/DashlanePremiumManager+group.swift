import Foundation
import Combine
import StoreKit

extension DashlanePremiumManager {
    public func fetchPurchasePlansForCurrentSession(using options: PlanOptions = [.includeFamilyPlans]) -> Future<[PurchasePlan], Error> {
        Future { completion in
            self.fetchPurchasePlansForCurrentSession(using: options, handler: completion)
        }
    }

    public func fetchPurchasePlanGroupsForCurrentSession(using options: PlanOptions = [.includeFamilyPlans]) -> AnyPublisher<[PurchasePlan.Kind: PlanTier], Error> {
        fetchPurchasePlansForCurrentSession().map { plans in
            Dictionary(grouping: plans, by: \.kind)
                .compactMapValues { plans in
                    guard let first = plans.first else {
                        return nil
                    }
                    return PlanTier(kind: first.kind,
                                    plans: plans,
                                    capabilities: first.capabilities)
                }
        }.eraseToAnyPublisher()
    }
}
