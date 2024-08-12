import Combine
import DashTypes
import DashlaneAPI
import Foundation

public struct PremiumStatusServicesSuit: DependenciesContainer {
  public let statusProvider: PremiumStatusProvider
  public let userSpacesService: UserSpacesService
  public let capabilityService: CapabilityService

  init(statusProvider: PremiumStatusProvider) async {
    self.statusProvider = statusProvider
    userSpacesService = UserSpacesService(provider: statusProvider)
    capabilityService = CapabilityService(provider: statusProvider)
  }
}

extension PremiumStatusServicesSuit {
  public init(
    client: UserDeviceAPIClient,
    cache: PremiumStatusCache,
    refreshTrigger: any Publisher<Void, Never>,
    logger: Logger
  ) async throws {
    statusProvider = try await PremiumStatusAPIProvider(
      client: client, cache: cache, refreshTrigger: refreshTrigger, logger: logger)
    userSpacesService = UserSpacesService(provider: statusProvider)
    capabilityService = CapabilityService(provider: statusProvider)
  }
}

extension PremiumStatusServicesSuit {
  public init(cache: PremiumStatusCache) throws {
    statusProvider = try PremiumStatusFromCacheProvider(cache: cache)
    userSpacesService = UserSpacesService(provider: statusProvider)
    capabilityService = CapabilityService(provider: statusProvider)
  }
}
