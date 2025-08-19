import Foundation

public struct SecurefileQuota: Codable, Hashable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case remaining = "remaining"
    case max = "max"
  }

  public let remaining: Int
  public let max: Int

  public init(remaining: Int, max: Int) {
    self.remaining = remaining
    self.max = max
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(remaining, forKey: .remaining)
    try container.encode(max, forKey: .max)
  }
}
