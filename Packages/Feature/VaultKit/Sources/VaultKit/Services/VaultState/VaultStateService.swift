import Combine
import CoreFeature
import CorePremium
import CoreTypes
import Foundation

public final class VaultStateService: VaultStateServiceProtocol, VaultKitServicesInjecting {
  @Published
  public var vaultState: VaultState = .default

  public init(
    vaultItemsLimitService: VaultItemsLimitService,
    premiumStatusProvider: PremiumStatusProvider,
    featureService: FeatureServiceProtocol
  ) {

    vaultItemsLimitService.$credentialsLimit
      .combineLatest(premiumStatusProvider.statusPublisher)
      .map({ (vaultLimit, premiumStatus) -> VaultState in
        switch vaultLimit {
        case let .limited(count, limit, enforceFreeze)
        where count > limit && enforceFreeze && premiumStatus.b2cStatus.statusCode == .free
          && featureService.isEnabled(.freeUsersFrozenState):
          .frozen
        case .limited, .reachingLimit, .unlimited:
          .default
        }
      })
      .removeDuplicates()
      .assign(to: &$vaultState)
  }

  public func vaultStatePublisher() -> AnyPublisher<VaultState, Never> {
    return $vaultState.eraseToAnyPublisher()
  }
}
