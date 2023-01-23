import Foundation

public enum Permission: String, Codable, Equatable, CaseIterable {
    case admin = "admin"
    case limited = "limited"
}
