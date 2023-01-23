import Foundation

public struct CoreSessionSettings: Codable {
    public let time: UInt64
    public let content: String

    public init(time: UInt64, content: String) {
        self.time = time
        self.content = content
    }
}
