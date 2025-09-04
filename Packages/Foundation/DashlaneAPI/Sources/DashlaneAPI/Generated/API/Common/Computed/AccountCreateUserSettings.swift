import Foundation

public struct AccountCreateUserSettings: Codable, Hashable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case content = "content"
    case time = "time"
  }

  public let content: String
  public let time: Int

  public init(content: String, time: Int) {
    self.content = content
    self.time = time
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(content, forKey: .content)
    try container.encode(time, forKey: .time)
  }
}
