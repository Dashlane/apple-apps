import Foundation

public struct ItemForEmailing: Codable, Equatable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case name = "name"
    case type = "type"
  }

  public enum `Type`: String, Sendable, Equatable, CaseIterable, Codable {
    case password = "password"
    case note = "note"
    case secret = "secret"
    case undecodable
    public init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      let rawValue = try container.decode(String.self)
      self = Self(rawValue: rawValue) ?? .undecodable
    }
  }

  public let name: String
  public let type: `Type`

  public init(name: String, type: `Type`) {
    self.name = name
    self.type = type
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(name, forKey: .name)
    try container.encode(type, forKey: .type)
  }
}
