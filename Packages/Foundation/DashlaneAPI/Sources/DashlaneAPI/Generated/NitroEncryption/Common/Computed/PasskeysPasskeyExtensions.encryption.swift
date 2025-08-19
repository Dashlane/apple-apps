import Foundation

public struct PasskeysPasskeyExtensions: Codable, Hashable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case credProps = "credProps"
  }

  public let credProps: Bool?

  public init(credProps: Bool? = nil) {
    self.credProps = credProps
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(credProps, forKey: .credProps)
  }
}
