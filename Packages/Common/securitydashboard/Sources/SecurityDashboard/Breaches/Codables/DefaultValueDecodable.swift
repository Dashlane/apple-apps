import Foundation

public protocol DefaultValueDecodable: RawRepresentable, Codable {
  static var defaultDecodedValue: Self { get }
}

extension DefaultValueDecodable where RawValue == String {
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let value = try? container.decode(String.self),
      let data = Self.init(rawValue: value)
    {
      self = data
    } else {
      self = Self.defaultDecodedValue
    }
  }
}
