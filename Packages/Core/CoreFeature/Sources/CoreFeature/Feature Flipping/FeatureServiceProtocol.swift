import Foundation

public protocol FeatureServiceProtocol {
  func isEnabled(_ feature: ControlledFeature) -> Bool
  func enabledFeatures() -> Set<ControlledFeature>
  var isLabsAvailable: Bool { get }
  func labs() async throws -> [LabsExperience]
  func save(_ experiences: [LabsExperience])
}
