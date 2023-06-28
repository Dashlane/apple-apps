import Foundation

public struct ItemForEmailing: Codable, Equatable {

        public enum `Type`: String, Codable, Equatable, CaseIterable {
        case password = "password"
        case note = "note"
    }

    private enum CodingKeys: String, CodingKey {
        case name = "name"
        case type = "type"
    }

        public let name: String

        public let type: `Type`

    public init(name: String, type: `Type`) {
        self.name = name
        self.type = type
    }
}
