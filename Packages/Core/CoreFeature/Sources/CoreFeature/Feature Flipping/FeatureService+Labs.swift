import DashTypes
import DashlaneAPI
import Foundation

extension FeatureService {

  internal var labsActivatedFeatures: [ControlledFeature] {
    storedActiveLabs().compactMap { ControlledFeature(rawValue: $0) }
  }

  public func fetchLabs() async throws -> [AppAPIClient.Features.ListAvailableLabs.Response
    .LabsElement]
  {
    let availableLabs = try await apiAppClient.listAvailableLabs()

    let displayedLabs = availableLabs.labs
      .filter { ControlledFeature.allCases.map(\.rawValue).contains($0.featureName) }

    return displayedLabs
  }

  @MainActor public func save(_ experiences: [LabsExperience]) {
    var activeLabs = storedActiveLabs()
    for experience in experiences {
      if experience.isOn {
        activeLabs.insert(experience.feature.rawValue)
      } else {
        activeLabs.remove(experience.feature.rawValue)
      }
    }

    do {
      let encoded = try JSONEncoder().encode(activeLabs)
      try labsStorage.store(encoded)
    } catch {
      logger.error("cannot persist labs", error: error)
    }
  }

  internal func storedActiveLabs() -> Set<String> {
    guard labsStorage.hasStoredData() else {
      return []
    }
    do {
      let labsData = try labsStorage.retrieve()
      let rawLabs = try JSONDecoder().decode(Set<String>.self, from: labsData)
      return rawLabs
    } catch {
      logger.error("cannot retrieve labs", error: error)
      return []
    }
  }
}
