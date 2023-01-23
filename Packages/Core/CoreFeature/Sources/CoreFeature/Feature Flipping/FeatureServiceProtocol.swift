import Foundation

public protocol FeatureServiceProtocol {
    func isEnabled(_ feature: ControlledFeature) -> Bool
    func enabledFeatures() -> Set<ControlledFeature>
}
