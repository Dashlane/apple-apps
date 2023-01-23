import Foundation

public enum BreachesStatus: String, Codable, Equatable, CaseIterable {
    case legacy = "legacy"
    case live = "live"
    case staging = "staging"
    case deleted = "deleted"
}
