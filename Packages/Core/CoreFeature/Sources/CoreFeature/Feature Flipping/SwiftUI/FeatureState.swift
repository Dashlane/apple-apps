import Foundation
import SwiftUI
import DashTypes

@propertyWrapper
public struct FeatureState: DynamicProperty {
    private let feature: ControlledFeature

    @Environment(\.enabledFeatures)
    var localEnabledFeatures: Set<ControlledFeature>

    @GlobalEnvironment(\.enabledAtLoginFeatures)
    var globalEnabledFeatures: Set<ControlledFeature>

    public var wrappedValue: Bool {
        globalEnabledFeatures.contains(feature) || localEnabledFeatures.contains(feature)
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
        } set {
            self[FeatureFlipsEnvironmentKey.self] = newValue
        }
    }
}

extension GlobalEnvironmentValues {
    public var enabledAtLoginFeatures: Set<ControlledFeature> {
        get {
            return self[FeatureFlipsEnvironmentKey.self]
        } set {
            self[FeatureFlipsEnvironmentKey.self] = newValue
        }
    }
}
