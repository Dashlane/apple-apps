import Foundation
import DashTypes

public struct FeatureFlip: Hashable {
        public enum UpdateMode: String {
        case perLogin
        case perFlipRefresh
    }

    public let name: String
    public let updateMode: UpdateMode

    public init(name: String, updateMode: UpdateMode) {
        self.name = name
        self.updateMode = updateMode
    }
}
