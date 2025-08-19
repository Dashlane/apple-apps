import Foundation

public struct PasskeysPasskeyCredProps: Codable, Hashable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case rk = "rk"
  }

  public let rk: Bool?

  public init(rk: Bool? = nil) {
    self.rk = rk
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(rk, forKey: .rk)
  }
}
