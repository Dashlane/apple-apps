import DashlaneAPI
import Foundation

extension FeatureService {
  public func refreshFlips(isInitialFetch: Bool = false) async throws {

    let currentlyLoaded = !isInitialFetch ? features.map { $0.rawValue } : []

    logger.debug("Start to refresh feature flips, previously loaded flips [\(currentlyLoaded)]")

    let controlledFeatures = Set(ControlledFeature.allCases.map { $0.rawValue })
    let serverEnabledFlips = try await fetchEnabledFlips(includedIn: controlledFeatures)
    let updatedFlips = Set(currentlyLoaded).symmetricDifference(serverEnabledFlips)

    logger.debug("Flips enabled server side [\(serverEnabledFlips)]")
    logger.debug("Flips that changed since the last call [\(updatedFlips)]")

    await store(serverEnabledFlips)

    guard isInitialFetch else {
      return
    }
    self.features = Set(serverEnabledFlips.compactMap(ControlledFeature.init(rawValue:)))
  }

  internal func fetchEnabledFlips(includedIn controlledFlips: Set<String>) async throws -> Set<
    String
  > {
    let response = try await apiClient.getAndEvaluateForUser(
      features: ControlledFeature.allCases.map { $0.rawValue })

    let flipHandledThatAreEnabledByServer = controlledFlips.intersection(response.enabledFeatures)

    return flipHandledThatAreEnabledByServer
  }
}
