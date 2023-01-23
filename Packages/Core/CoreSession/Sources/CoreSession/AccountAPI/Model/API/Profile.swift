import Foundation

public struct Profile: Codable, Hashable {
    public let login: String
    public let deviceAccessKey: String
}
