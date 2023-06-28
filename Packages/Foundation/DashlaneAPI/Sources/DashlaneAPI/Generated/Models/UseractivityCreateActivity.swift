import Foundation

public struct UseractivityCreateActivity: Codable, Equatable {

    private enum CodingKeys: String, CodingKey {
        case securityIndex = "securityIndex"
    }

    public let securityIndex: Int?

    public init(securityIndex: Int? = nil) {
        self.securityIndex = securityIndex
    }
}
