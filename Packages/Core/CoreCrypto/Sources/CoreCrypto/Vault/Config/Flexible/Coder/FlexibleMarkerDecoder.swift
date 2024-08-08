import Foundation

struct FlexibleMarkerDecoder {
  enum DecodeError: Swift.Error {
    case cannotConvertToData
    case noFlexibleSeparator
    case nothingToParse
    case wrongType(Any)
  }

  private let data: Data
  private var currentIndex: Int = 1

  init(encryptedData: Data) throws {
    guard encryptedData.first == FlexibleCryptoConfiguration.markerSeperator else {
      throw DecodeError.noFlexibleSeparator
    }
    data = encryptedData
  }

  mutating func decode(_ type: Int.Type) throws -> Int {
    let value: String = try decode(String.self)
    guard let value = Int(value) else {
      throw DecodeError.wrongType(Int.self)
    }

    return value
  }

  mutating func decode<T: RawRepresentable<String>>(_ type: T.Type) throws -> T {
    let value: String = try decode(String.self)
    guard let value = T(rawValue: value) else {
      throw DecodeError.wrongType(T.self)
    }
    return value
  }

  mutating func decode(_ type: String.Type) throws -> String {
    guard currentIndex < data.count,
      let endIndex = data[currentIndex...].firstIndex(
        of: FlexibleCryptoConfiguration.markerSeperator)
    else {
      throw DecodeError.nothingToParse
    }

    guard let value = String(data: data[currentIndex..<endIndex], encoding: .utf8) else {
      throw DecodeError.wrongType(String.self)
    }
    currentIndex = endIndex + 1

    return value
  }

  mutating func decode<T: FlexibleMarkerDecodable>(_ type: T.Type) throws -> T {
    return try T(decoder: &self)
  }
}

protocol FlexibleMarkerDecodable {
  init(decoder: inout FlexibleMarkerDecoder) throws
}

extension FlexibleMarkerDecodable {
  init(encryptedData: Data) throws {
    var decoder = try FlexibleMarkerDecoder(encryptedData: encryptedData)
    try self.init(decoder: &decoder)
  }

  init(rawConfigMarker: String) throws {
    guard let encryptedData = rawConfigMarker.data(using: .utf8) else {
      throw FlexibleMarkerDecoder.DecodeError.cannotConvertToData
    }

    try self.init(encryptedData: encryptedData)
  }

}
