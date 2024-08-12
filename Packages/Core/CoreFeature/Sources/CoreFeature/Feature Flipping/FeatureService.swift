import Combine
import DashTypes
import DashlaneAPI
import Foundation
import SwiftTreats

public class FeatureService: FeatureServiceProtocol {

  typealias LabsElement = AppAPIClient.Features.ListAvailableLabs.Response.LabsElement

  internal let apiClient: UserDeviceAPIClient.Features
  internal let apiAppClient: AppAPIClient.Features
  internal let login: Login
  internal let logger: Logger
  private let storage: FeatureFlipServiceStorage
  internal let labsStorage: LabsServiceStorage

  @Atomic
  public internal(set) var features = Set<ControlledFeature>()

  public init(
    login: Login,
    apiClient: UserDeviceAPIClient.Features,
    apiAppClient: AppAPIClient.Features,
    storage: FeatureFlipServiceStorage,
    labsStorage: LabsServiceStorage,
    logger: Logger,
    useCacheOnly: Bool = false
  ) async {
    self.apiClient = apiClient
    self.apiAppClient = apiAppClient
    self.login = login
    self.storage = storage
    self.labsStorage = labsStorage
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
    guard !storedActiveLabs().contains(feature.rawValue) else { return true }
    return enabledFeatures().contains(feature)
  }

  public func enabledFeatures() -> Set<ControlledFeature> {
    var enabledFeatures = features.union(labsActivatedFeatures)
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

extension FeatureService {
  public var isLabsAvailable: Bool {
    return BuildEnvironment.current == .debug || BuildEnvironment.current.isQA
      || BuildEnvironment.current.isNightly
  }

  public func labs() async throws -> [LabsExperience] {
    let enableFeatures = enabledFeatures().map { $0.rawValue }
    let activeLabs = storedActiveLabs()
    let serverLabs = try await fetchLabs()
    return serverLabs.compactMap { lab in
      let isOn = enableFeatures.contains(lab.featureName) || activeLabs.contains(lab.featureName)
      guard let feature = ControlledFeature(rawValue: lab.featureName) else {
        return nil
      }
      return LabsExperience(
        feature: feature, displayName: lab.displayName, displayDescription: lab.displayDescription,
        isOn: isOn)
    }
  }
}

extension FeatureServiceProtocol where Self == MockFeatureService {
  public static func mock(
    features: [ControlledFeature] = [], labsExperiences: [LabsExperience] = []
  ) -> MockFeatureService {
    return MockFeatureService(features: features, labsExperiences: labsExperiences)
  }
}

public class MockFeatureService: FeatureServiceProtocol {
  var features: [ControlledFeature]
  var labsExperiences: [LabsExperience]

  public var isLabsAvailable: Bool = false

  public init(features: [ControlledFeature] = [], labsExperiences: [LabsExperience] = []) {
    self.features = features
    self.labsExperiences = labsExperiences
  }

  public func isEnabled(_ feature: ControlledFeature) -> Bool {
    features.contains(feature)
  }

  public func enabledFeatures() -> Set<ControlledFeature> {
    return Set(features)
  }

  public func labs() -> [LabsExperience] {
    return labsExperiences
  }

  public func save(_ experiences: [LabsExperience]) {}
}
