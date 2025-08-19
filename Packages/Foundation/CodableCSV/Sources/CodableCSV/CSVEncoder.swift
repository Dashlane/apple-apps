import Foundation

public struct CSVEncoder {
  let delimiter: Character

  public init(delimiter: Character = ",") {
    self.delimiter = delimiter
  }

  public func encode<T>(_ values: [T]) throws -> String where T: Encodable {
    guard let firstValue = values.first else {
      throw EncodingError.invalidValue(
        values, EncodingError.Context(codingPath: [], debugDescription: "Values array is empty"))
    }

    let firstRowEncoder = CSVRowEncoder(delimiter: delimiter)
    try firstValue.encode(to: firstRowEncoder)
    let headers = firstRowEncoder.headerRow.joined(separator: String(delimiter)) + "\n"
    var rows: String = firstRowEncoder.currentRow.joined(separator: String(delimiter))

    for value in values.dropFirst() {
      let rowEncoder = CSVRowEncoder(delimiter: delimiter)
      try value.encode(to: rowEncoder)
      rows += "\n" + rowEncoder.currentRow.joined(separator: String(delimiter))
    }

    return headers + rows
  }
}

private class CSVRowEncoder: Encoder {
  var codingPath: [CodingKey] = []
  var userInfo: [CodingUserInfoKey: Any] = [:]
  var headerRow = [String]()
  var currentRow = [String]()

  private let delimiter: Character
  private let escapingCharacters: Set<Character>

  init(delimiter: Character, headerRow: [String] = []) {
    self.delimiter = delimiter
    self.headerRow = headerRow
    self.escapingCharacters = Set([delimiter, "\n", "\r", "\""])
    currentRow = Array(repeating: "", count: headerRow.count)
  }

  private func append(_ value: String, forKey key: String, escape: Bool = true) {
    let key = key.snakeCased()

    if !headerRow.contains(key) {
      headerRow.append(key)
      currentRow.append("")
    }

    if let index = headerRow.firstIndex(of: key) {
      currentRow[index] = escape ? escapeValue(value) : value
    }
  }

  private func escapeValue(_ value: String) -> String {
    let needsEscaping = value.contains { escapingCharacters.contains($0) }
    if needsEscaping {
      let escapedValue = value.replacingOccurrences(of: #"""#, with: #""""#)
      return "\"\(escapedValue)\""
    }
    return value
  }

  func container<Key>(keyedBy _: Key.Type) -> KeyedEncodingContainer<Key> where Key: CodingKey {
    return KeyedEncodingContainer(CSVKeyedEncodingContainer<Key>(encoder: self))
  }

  func unkeyedContainer() -> UnkeyedEncodingContainer {
    return CSVUnkeyedEncodingContainer(encoder: self)
  }

  func singleValueContainer() -> SingleValueEncodingContainer {
    return CSVSingleValueEncodingContainer(encoder: self)
  }

  private struct CSVKeyedEncodingContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {
    var codingPath: [CodingKey] = []
    private let encoder: CSVRowEncoder

    init(encoder: CSVRowEncoder) {
      self.encoder = encoder
    }

    mutating func encodeNil(forKey key: Key) throws {
      encoder.append("", forKey: key.stringValue)
    }

    mutating func encode<T>(_ value: T, forKey key: Key) throws where T: Encodable {
      let localEncoder = CSVRowEncoder(delimiter: encoder.delimiter)
      try value.encode(to: localEncoder)
      let encodedValue = localEncoder.currentRow.first ?? ""
      self.encoder.append(encodedValue, forKey: key.stringValue, escape: false)
    }

    mutating func encode(_ value: String, forKey key: Key) throws {
      self.encoder.append(value, forKey: key.stringValue)
    }

    mutating func encodeIfPresent<T>(_ value: T?, forKey key: Key) throws where T: Encodable {
      if let value = value {
        try encode(value, forKey: key)
      } else {
        try encodeNil(forKey: key)
      }
    }

    mutating func encodeIfPresent(_ value: Int?, forKey key: Key) throws {
      if let value = value {
        try encode(value, forKey: key)
      } else {
        try encodeNil(forKey: key)
      }
    }

    public mutating func encodeIfPresent(_ value: Bool?, forKey key: Key) throws {
      if let value = value {
        try encode(value, forKey: key)
      } else {
        try encodeNil(forKey: key)
      }
    }

    public mutating func encodeIfPresent(_ value: String?, forKey key: Key) throws {
      if let value = value {
        try encode(value, forKey: key)
      } else {
        try encodeNil(forKey: key)
      }
    }

    public mutating func encodeIfPresent(_ value: Double?, forKey key: Key) throws {
      if let value = value {
        try encode(value, forKey: key)
      } else {
        try encodeNil(forKey: key)
      }
    }

    public mutating func encodeIfPresent(_ value: Float?, forKey key: Key) throws {
      if let value = value {
        try encode(value, forKey: key)
      } else {
        try encodeNil(forKey: key)
      }
    }

    public mutating func encodeIfPresent(_ value: Int8?, forKey key: Key) throws {
      if let value = value {
        try encode(value, forKey: key)
      } else {
        try encodeNil(forKey: key)
      }
    }

    public mutating func encodeIfPresent(_ value: Int16?, forKey key: Key) throws {
      if let value = value {
        try encode(value, forKey: key)
      } else {
        try encodeNil(forKey: key)
      }
    }

    public mutating func encodeIfPresent(_ value: Int32?, forKey key: Key) throws {
      if let value = value {
        try encode(value, forKey: key)
      } else {
        try encodeNil(forKey: key)
      }
    }

    public mutating func encodeIfPresent(_ value: Int64?, forKey key: Key) throws {
      if let value = value {
        try encode(value, forKey: key)
      } else {
        try encodeNil(forKey: key)
      }
    }

    public mutating func encodeIfPresent(_ value: UInt?, forKey key: Key) throws {
      if let value = value {
        try encode(value, forKey: key)
      } else {
        try encodeNil(forKey: key)
      }
    }

    public mutating func encodeIfPresent(_ value: UInt8?, forKey key: Key) throws {
      if let value = value {
        try encode(value, forKey: key)
      } else {
        try encodeNil(forKey: key)
      }
    }

    public mutating func encodeIfPresent(_ value: UInt16?, forKey key: Key) throws {
      if let value = value {
        try encode(value, forKey: key)
      } else {
        try encodeNil(forKey: key)
      }
    }

    public mutating func encodeIfPresent(_ value: UInt32?, forKey key: Key) throws {
      if let value = value {
        try encode(value, forKey: key)
      } else {
        try encodeNil(forKey: key)
      }
    }

    public mutating func encodeIfPresent(_ value: UInt64?, forKey key: Key) throws {
      if let value = value {
        try encode(value, forKey: key)
      } else {
        try encodeNil(forKey: key)
      }
    }

    mutating func nestedContainer<NestedKey>(keyedBy _: NestedKey.Type, forKey _: Key)
      -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey
    {
      fatalError("Nested encoding is not supported for CSV.")
    }

    mutating func nestedUnkeyedContainer(forKey _: Key) -> UnkeyedEncodingContainer {
      fatalError("Nested encoding is not supported for CSV.")
    }

    mutating func superEncoder() -> Encoder {
      return encoder
    }

    mutating func superEncoder(forKey _: Key) -> Encoder {
      return encoder
    }
  }

  private struct CSVUnkeyedEncodingContainer: UnkeyedEncodingContainer {
    var codingPath: [CodingKey] = []
    var count: Int = 0
    private let encoder: CSVRowEncoder

    init(encoder: CSVRowEncoder) {
      self.encoder = encoder
    }

    mutating func encodeNil() throws {
      encoder.append("", forKey: "")
    }

    mutating func encode<T>(_ value: T) throws where T: Encodable {
      let valueString = String(describing: value)
      encoder.append(valueString, forKey: "")
      count += 1
    }

    mutating func encode(_ value: String) throws {
      encoder.append(value, forKey: "")
      count += 1
    }

    mutating func nestedContainer<NestedKey>(keyedBy _: NestedKey.Type) -> KeyedEncodingContainer<
      NestedKey
    > where NestedKey: CodingKey {
      fatalError("Nested encoding is not supported for CSV.")
    }

    mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
      fatalError("Nested encoding is not supported for CSV.")
    }

    mutating func superEncoder() -> Encoder {
      return encoder
    }
  }

  private struct CSVSingleValueEncodingContainer: SingleValueEncodingContainer {
    var codingPath: [CodingKey] = []
    private let encoder: CSVRowEncoder

    init(encoder: CSVRowEncoder) {
      self.encoder = encoder
    }

    mutating func encodeNil() throws {
      encoder.append("", forKey: "")
    }

    mutating func encode<T>(_ value: T) throws where T: Encodable {
      let valueString = String(describing: value)
      encoder.append(valueString, forKey: "")
    }

    mutating func encode(_ value: String) throws {
      encoder.append(value, forKey: "")
    }
  }
}

extension String {
  func snakeCased() -> String {
    return reduce(into: "") { result, character in
      if character.isUppercase {
        if !result.isEmpty {
          result.append("_")
        }
        result.append(character.lowercased())
      } else {
        result.append(character)
      }
    }
  }
}
