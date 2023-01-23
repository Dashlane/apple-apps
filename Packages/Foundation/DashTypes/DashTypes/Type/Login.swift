import Foundation

public struct Login: Hashable, Codable {
    public let email: String

    public init(_ email: String) {
        self.email = email.lowercased().trimmingCharacters(in: CharacterSet.whitespaces)
    }
}
