import Foundation

private let jsonEncoder = JSONEncoder()
private let jsonDecoder = JSONDecoder()

@propertyWrapper
public struct JSONEncoded<T: Codable>: Codable {
  public var wrappedValue: T

  public init(_ wrappedValue: T) {
    self.wrappedValue = wrappedValue
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let string = try container.decode(String.self)
    guard let json = string.data(using: .utf8) else {
      throw DecodingError.dataCorrupted(
        .init(
          codingPath: decoder.codingPath, debugDescription: "Cannot create json data from string"))
    }
    wrappedValue = try jsonDecoder.decode(T.self, from: json)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    let json = try jsonEncoder.encode(wrappedValue)
    let string = String(data: json, encoding: .utf8)
    try container.encode(string)
  }
}

extension JSONEncoded: Equatable where T: Equatable {}
extension JSONEncoded: Hashable where T: Hashable {}

extension KeyedDecodingContainer {
  public func decode<T>(_ type: JSONEncoded<T?>.Type, forKey key: Key) throws -> JSONEncoded<T?>
  where T: Decodable {
    return try decodeIfPresent(type, forKey: key) ?? JSONEncoded<T?>(nil)
  }

  public func decode<T>(_ type: JSONEncoded<T>.Type, forKey key: Key) throws -> JSONEncoded<T>
  where T: Decodable & Defaultable {
    return (try? decodeIfPresent(type, forKey: key)) ?? JSONEncoded<T>(T.defaultValue)
  }
}

extension KeyedEncodingContainer {
  public mutating func encode<T>(_ jsonEncoded: JSONEncoded<T?>, forKey key: Key) throws
  where T: Decodable {
    if let value = jsonEncoded.wrappedValue {
      try encode(JSONEncoded(value), forKey: key)
    } else {
      try encodeNil(forKey: key)
    }
  }
}

extension JSONEncoded where T: Defaultable {
  public init() {
    self.init(T.defaultValue)
  }
}
