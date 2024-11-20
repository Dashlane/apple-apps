import Combine
import CoreFeature
import CorePremium
import Foundation

public final class VaultStateService: VaultStateServiceProtocol, VaultKitServicesInjecting {
  @Published
  private var vaultState: VaultState = .default

  public init(
    vaultItemsLimitService: VaultItemsLimitService,
    premiumStatusProvider: PremiumStatusProvider,
    featureService: FeatureServiceProtocol
  ) {

    vaultItemsLimitService.$credentialsLimit
      .combineLatest(premiumStatusProvider.statusPublisher)
      .map({ (limit, status) -> VaultState in
        if case let .limited(count, limit, enforceFreeze) = limit,
          count > limit,
          enforceFreeze,
          status.b2cStatus.statusCode == .free,
          featureService.isEnabled(.freeUsersFrozenState)
        {

          return .frozen
        }

        return .default
      })
      .assign(to: &$vaultState)
  }

  public func vaultStatePublisher() -> AnyPublisher<VaultState, Never> {
    return $vaultState.eraseToAnyPublisher()
  }
}
