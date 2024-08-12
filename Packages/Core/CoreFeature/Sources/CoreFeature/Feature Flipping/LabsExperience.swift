import Foundation

public struct LabsExperience: Sendable {
  public let feature: ControlledFeature
  public let displayName: String
  public let displayDescription: String
  public var isOn: Bool

  public init(
    feature: ControlledFeature, displayName: String, displayDescription: String, isOn: Bool
  ) {
    self.feature = feature
    self.displayName = displayName
    self.displayDescription = displayDescription
    self.isOn = isOn
  }
}

extension LabsExperience: Identifiable {
  public var id: String {
    feature.rawValue
  }
}
