import Combine
import CorePersonalData
import CorePremium
import Foundation

public class VaultItemsLimitService: VaultItemsLimitServiceProtocol {

  @Published
  public private(set) var credentialsLimit: VaultItemsLimit = .unlimited
  public var credentialsLimitPublisher: Published<VaultItemsLimit>.Publisher { $credentialsLimit }

  public init(
    capabilityService: CapabilityServiceProtocol,
    credentialsPublisher: some Publisher<some Collection<Credential>, Never>
  ) {

    credentialsPublisher
      .combineLatest(capabilityService.capabilitiesPublisher())
      .map({ ($0.count, $1) })
      .map({ (itemsCount, capabilities) -> VaultItemsLimit in
        capabilities.limit(
          for: .passwordsLimit,
          andItemCount: itemsCount)
      })
      .assign(to: &$credentialsLimit)
  }

  public func canAddNewItem(for vaultItem: VaultItem.Type) -> Bool {
    switch vaultItem {
    case is Credential.Type:
      return !credentialsLimit.isLimited
    default:
      return true
    }
  }

  public func canAddNewItem(for category: ItemCategory) -> Bool {
    switch category {
    case .credentials:
      return !credentialsLimit.isLimited
    default:
      return true
    }
  }
}

extension CapabilityServiceProtocol.Capabilities {
  fileprivate func limit(
    for capability: CapabilityKey,
    andItemCount itemsCount: Int
  ) -> VaultItemsLimit {
    guard let capability = self[capability] else {
      return .unlimited
    }
    guard let limit = capability.info?.limit else {
      return .unlimited
    }
    let remainingCount = limit - itemsCount
    let enforceFreeze = capability.info?.action == .enforceFreeze

    if remainingCount > 5 {
      return .unlimited
    } else if remainingCount > 0 {
      return .reachingLimit(count: itemsCount, limit: limit)
    } else {
      return .limited(count: itemsCount, limit: limit, enforceFreeze: enforceFreeze)
    }
  }
}
