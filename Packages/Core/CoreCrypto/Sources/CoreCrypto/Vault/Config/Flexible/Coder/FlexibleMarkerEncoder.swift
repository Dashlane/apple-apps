import Foundation
import LogFoundation

struct FlexibleMarkerEncoder {
  @Loggable
  enum EncodeError: Swift.Error {
    case encodeUTF8StringFail
  }

  private var data = Data([FlexibleCryptoConfiguration.markerSeperator])

  mutating func encode(_ value: Int) throws {
    try encode(String(value))
  }

  mutating func encode<T: RawRepresentable<String>>(_ value: T) throws {
    try encode(value.rawValue)
  }

  mutating func encode(_ value: String) throws {
    guard let encodedData = value.data(using: .utf8) else {
      throw EncodeError.encodeUTF8StringFail
    }
    data.append(contentsOf: encodedData)
    data.append(FlexibleCryptoConfiguration.markerSeperator)
  }

  mutating func encode<T: FlexibleMarkerEncodable>(_ value: T) throws {
    return try value.encode(to: &self)
  }

  func marker() -> Data {
    data
  }
}

protocol FlexibleMarkerEncodable {
  func encode(to: inout FlexibleMarkerEncoder) throws
}

extension FlexibleMarkerEncodable {
  func marker() throws -> Data {
    var encoder = FlexibleMarkerEncoder()
    try encoder.encode(self)
    return encoder.marker()
  }

  func rawConfigMarker() throws -> String {
    guard let marker = try String(data: marker(), encoding: .utf8) else {
      throw FlexibleMarkerEncoder.EncodeError.encodeUTF8StringFail
    }

    return marker
  }
}
