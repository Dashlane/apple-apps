import Foundation

struct SingleValueDecodeContainer: SingleValueDecodingContainer {
  let decoder: PersonalDataDecoderImpl
  let codingPath: [CodingKey]
  let options: PersonalDataDecoder.Options

  func decodeNil() -> Bool {
    return decoder.value == nil
  }

  func decode(_ type: String.Type) throws -> String {
    try decoder.unwrapString()
  }

  func decode(_ type: Bool.Type) throws -> Bool {
    try decoder.unwrapBool()
  }

  func decode(_ type: Double.Type) throws -> Double {
    try decoder.unwrapNumeric(Double.self)
  }

  func decode(_ type: Float.Type) throws -> Float {
    try decoder.unwrapNumeric(Float.self)
  }

  func decode(_ type: Int.Type) throws -> Int {
    try decoder.unwrapNumeric(Int.self)
  }

  func decode(_ type: Int8.Type) throws -> Int8 {
    try decoder.unwrapNumeric(Int8.self)
  }

  func decode(_ type: Int16.Type) throws -> Int16 {
    try decoder.unwrapNumeric(Int16.self)
  }

  func decode(_ type: Int32.Type) throws -> Int32 {
    try decoder.unwrapNumeric(Int32.self)
  }

  func decode(_ type: Int64.Type) throws -> Int64 {
    try decoder.unwrapNumeric(Int64.self)
  }

  func decode(_ type: UInt.Type) throws -> UInt {
    try decoder.unwrapNumeric(UInt.self)
  }

  func decode(_ type: UInt8.Type) throws -> UInt8 {
    try decoder.unwrapNumeric(UInt8.self)
  }

  func decode(_ type: UInt16.Type) throws -> UInt16 {
    try decoder.unwrapNumeric(UInt16.self)
  }

  func decode(_ type: UInt32.Type) throws -> UInt32 {
    try decoder.unwrapNumeric(UInt32.self)
  }

  func decode(_ type: UInt64.Type) throws -> UInt64 {
    try decoder.unwrapNumeric(UInt64.self)
  }

  func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
    try decoder.unwrap(as: type)
  }
}
