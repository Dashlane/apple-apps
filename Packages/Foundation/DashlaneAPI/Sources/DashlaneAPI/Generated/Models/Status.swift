import Foundation

public enum Status: String, Codable, Equatable, CaseIterable {
    case pending = "pending"
    case accepted = "accepted"
    case refused = "refused"
    case revoked = "revoked"
}
