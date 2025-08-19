import CoreTypes
import Foundation
import SwiftUI

@propertyWrapper
public struct FeatureState: DynamicProperty {
  private let feature: ControlledFeature

  @Environment(\.enabledFeatures)
  var features: Set<ControlledFeature>

  public var wrappedValue: Bool {
    features.contains(feature)
  }

  public init(_ feature: ControlledFeature) {
    self.feature = feature
  }
}

public struct FeatureFlipsEnvironmentKey: EnvironmentKey {
  public static var defaultValue: Set<ControlledFeature> = []
}

extension EnvironmentValues {
  public var enabledFeatures: Set<ControlledFeature> {
    get {
      return self[FeatureFlipsEnvironmentKey.self]
    }
    set {
      self[FeatureFlipsEnvironmentKey.self] = newValue
    }
  }
}
