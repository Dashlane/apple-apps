import Combine
import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation
import SwiftTreats

public class FeatureService: FeatureServiceProtocol {

  internal let apiClient: UserDeviceAPIClient.Features
  internal let apiAppClient: AppAPIClient.Features
  internal let login: Login
  internal let logger: Logger
  private let storage: FeatureFlipServiceStorage

  @Atomic
  public internal(set) var features = Set<ControlledFeature>()

  public init(
    login: Login,
    apiClient: UserDeviceAPIClient.Features,
    apiAppClient: AppAPIClient.Features,
    storage: FeatureFlipServiceStorage,
    logger: Logger,
    useCacheOnly: Bool = false
  ) async {
    self.apiClient = apiClient
    self.apiAppClient = apiAppClient
    self.login = login
    self.storage = storage
    self.logger = logger

    guard !useCacheOnly else {
      await retrieveStoredFlips()
      return
    }

    if !storage.hasStoredData() {
      do {
        try await refreshFlips(isInitialFetch: true)
      } catch {
        logger.error("cannot retrieve feature flips", error: error)
      }
    } else {
      await retrieveStoredFlips()
      Task.detached {
        try? await self.refreshFlips(isInitialFetch: false)
      }
    }
  }

  public func isEnabled(_ feature: ControlledFeature) -> Bool {
    return enabledFeatures().contains(feature)
  }

  public func enabledFeatures() -> Set<ControlledFeature> {
    var enabledFeatures = features
    #if DEBUG
      enabledFeatures = enabledFeatures.union(ControlledFeature.forcedFeatureFlips)
    #endif
    return enabledFeatures
  }

  @MainActor
  internal func retrieveStoredFlips() {
    guard storage.hasStoredData() else {
      logger.info("no feature flips stored")
      return
    }
    do {
      let flipsData = try storage.retrieve()
      let rawFlips = try JSONDecoder().decode(Set<String>.self, from: flipsData)
      self.features = Set(rawFlips.compactMap { ControlledFeature(rawValue: $0) })
    } catch {
      logger.error("cannot retrieve feature flips", error: error)
    }
  }

  @MainActor
  internal func store(_ serverEnabledFlips: Set<String>) {
    do {
      let encoded = try JSONEncoder().encode(serverEnabledFlips)
      try storage.store(encoded)
    } catch {
      logger.error("cannot persist feature flips", error: error)
    }
  }
}

extension FeatureServiceProtocol where Self == MockFeatureService {
  public static func mock(features: [ControlledFeature] = []) -> MockFeatureService {
    return MockFeatureService(features: features)
  }
}

public class MockFeatureService: FeatureServiceProtocol {
  var features: [ControlledFeature]

  init(features: [ControlledFeature] = []) {
    self.features = features
  }

  public func isEnabled(_ feature: ControlledFeature) -> Bool {
    features.contains(feature)
  }

  public func enabledFeatures() -> Set<ControlledFeature> {
    return Set(features)
  }
}
