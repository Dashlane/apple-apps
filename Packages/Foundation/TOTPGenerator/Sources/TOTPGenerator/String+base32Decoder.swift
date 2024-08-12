import Foundation

public func base32Encode(_ data: Data) -> String {
  return data.withUnsafeBytes {
    base32encode($0.baseAddress!, $0.count, alphabetEncodeTable)
  }
}

public func base32HexEncode(_ data: Data) -> String {
  return data.withUnsafeBytes {
    base32encode($0.baseAddress!, $0.count, extendedHexAlphabetEncodeTable)
  }
}

public func base32DecodeToData(_ string: String) -> Data? {
  return base32decode(string, alphabetDecodeTable).flatMap(Data.init(_:))
}

public func base32HexDecodeToData(_ string: String) -> Data? {
  return base32decode(string, extendedHexAlphabetDecodeTable).flatMap(Data.init(_:))
}

public func base32Encode(_ array: [UInt8]) -> String {
  return base32encode(array, array.count, alphabetEncodeTable)
}

public func base32HexEncode(_ array: [UInt8]) -> String {
  return base32encode(array, array.count, extendedHexAlphabetEncodeTable)
}

public func base32Decode(_ string: String) -> [UInt8]? {
  return base32decode(string, alphabetDecodeTable)
}

public func base32HexDecode(_ string: String) -> [UInt8]? {
  return base32decode(string, extendedHexAlphabetDecodeTable)
}

extension String {
  public var base32DecodedData: Data? {
    return base32DecodeToData(self)
  }

  public var base32EncodedString: String {
    return utf8CString.withUnsafeBufferPointer {
      base32encode($0.baseAddress!, $0.count - 1, alphabetEncodeTable)
    }
  }

  public func base32DecodedString(_ encoding: String.Encoding = .utf8) -> String? {
    return base32DecodedData.flatMap {
      String(data: $0, encoding: .utf8)
    }
  }

  public var base32HexDecodedData: Data? {
    return base32HexDecodeToData(self)
  }

  public var base32HexEncodedString: String {
    return utf8CString.withUnsafeBufferPointer {
      base32encode($0.baseAddress!, $0.count - 1, extendedHexAlphabetEncodeTable)
    }
  }

  public func base32HexDecodedString(_ encoding: String.Encoding = .utf8) -> String? {
    return base32HexDecodedData.flatMap {
      String(data: $0, encoding: .utf8)
    }
  }
}

extension Data {
  public var base32EncodedString: String {
    return base32Encode(self)
  }

  public var base32EncodedData: Data {
    return base32EncodedString.dataUsingUTF8StringEncoding
  }

  public var base32DecodedData: Data? {
    return String(data: self, encoding: .utf8).flatMap(base32DecodeToData)
  }

  public var base32HexEncodedString: String {
    return base32HexEncode(self)
  }

  public var base32HexEncodedData: Data {
    return base32HexEncodedString.dataUsingUTF8StringEncoding
  }

  public var base32HexDecodedData: Data? {
    return String(data: self, encoding: .utf8).flatMap(base32HexDecodeToData)
  }
}

let alphabetEncodeTable: [Int8] = [
  "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S",
  "T", "U", "V", "W", "X", "Y", "Z", "2", "3", "4", "5", "6", "7",
].map { (c: UnicodeScalar) -> Int8 in Int8(c.value) }

let extendedHexAlphabetEncodeTable: [Int8] = [
  "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F", "G", "H", "I",
  "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V",
].map { (c: UnicodeScalar) -> Int8 in Int8(c.value) }

private func base32encode(_ data: UnsafeRawPointer, _ length: Int, _ table: [Int8]) -> String {
  if length == 0 {
    return ""
  }
  var length = length

  var bytes = data.assumingMemoryBound(to: UInt8.self)

  let resultBufferSize = Int(ceil(Double(length) / 5)) * 8 + 1
  let resultBuffer = UnsafeMutablePointer<Int8>.allocate(capacity: resultBufferSize)
  var encoded = resultBuffer

  while length >= 5 {
    encoded[0] = table[Int(bytes[0] >> 3)]
    encoded[1] = table[Int((bytes[0] & 0b00000111) << 2 | bytes[1] >> 6)]
    encoded[2] = table[Int((bytes[1] & 0b00111110) >> 1)]
    encoded[3] = table[Int((bytes[1] & 0b00000001) << 4 | bytes[2] >> 4)]
    encoded[4] = table[Int((bytes[2] & 0b00001111) << 1 | bytes[3] >> 7)]
    encoded[5] = table[Int((bytes[3] & 0b01111100) >> 2)]
    encoded[6] = table[Int((bytes[3] & 0b00000011) << 3 | bytes[4] >> 5)]
    encoded[7] = table[Int((bytes[4] & 0b00011111))]
    length -= 5
    encoded = encoded.advanced(by: 8)
    bytes = bytes.advanced(by: 5)
  }

  var byte0: UInt8
  var byte1: UInt8
  var byte2: UInt8
  var byte3: UInt8
  var byte4: UInt8
  (byte0, byte1, byte2, byte3, byte4) = (0, 0, 0, 0, 0)
  switch length {
  case 4:
    byte3 = bytes[3]
    encoded[6] = table[Int((byte3 & 0b00000011) << 3 | byte4 >> 5)]
    encoded[5] = table[Int((byte3 & 0b01111100) >> 2)]
    fallthrough
  case 3:
    byte2 = bytes[2]
    encoded[4] = table[Int((byte2 & 0b00001111) << 1 | byte3 >> 7)]
    fallthrough
  case 2:
    byte1 = bytes[1]
    encoded[3] = table[Int((byte1 & 0b00000001) << 4 | byte2 >> 4)]
    encoded[2] = table[Int((byte1 & 0b00111110) >> 1)]
    fallthrough
  case 1:
    byte0 = bytes[0]
    encoded[1] = table[Int((byte0 & 0b00000111) << 2 | byte1 >> 6)]
    encoded[0] = table[Int(byte0 >> 3)]
  default: break
  }

  let pad = Int8(UnicodeScalar("=").value)
  switch length {
  case 0:
    encoded[0] = 0
  case 1:
    encoded[2] = pad
    encoded[3] = pad
    fallthrough
  case 2:
    encoded[4] = pad
    fallthrough
  case 3:
    encoded[5] = pad
    encoded[6] = pad
    fallthrough
  case 4:
    encoded[7] = pad
    fallthrough
  default:
    encoded[8] = 0
  }

  if let base32Encoded = String(validatingUTF8: resultBuffer) {
    resultBuffer.deallocate()
    return base32Encoded
  } else {
    resultBuffer.deallocate()
    fatalError("internal error")
  }
}

let __: UInt8 = 255
let alphabetDecodeTable: [UInt8] = [
  __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
  __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
  __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
  __, __, 26, 27, 28, 29, 30, 31, __, __, __, __, __, __, __, __,
  __, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14,
  15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, __, __, __, __, __,
  __, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14,
  15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, __, __, __, __, __,
  __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
  __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
  __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
  __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
  __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
  __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
  __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
  __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
]

let extendedHexAlphabetDecodeTable: [UInt8] = [
  __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
  __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
  __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
  0, 1, 2, 3, 4, 5, 6, 7, 8, 9, __, __, __, __, __, __,
  __, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24,
  25, 26, 27, 28, 29, 30, 31, __, __, __, __, __, __, __, __, __,
  __, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24,
  25, 26, 27, 28, 29, 30, 31, __, __, __, __, __, __, __, __, __,
  __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
  __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
  __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
  __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
  __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
  __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
  __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
  __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
]

private func base32decode(_ string: String, _ table: [UInt8]) -> [UInt8]? {
  let length = string.unicodeScalars.count
  if length == 0 {
    return []
  }

  func getLeastPaddingLength(_ string: String) -> Int {
    if string.hasSuffix("======") {
      return 6
    } else if string.hasSuffix("====") {
      return 4
    } else if string.hasSuffix("===") {
      return 3
    } else if string.hasSuffix("=") {
      return 1
    } else {
      return 0
    }
  }

  let leastPaddingLength = getLeastPaddingLength(string)
  if let index = string.unicodeScalars.firstIndex(where: {
    $0.value > 0xff || table[Int($0.value)] > 31
  }) {
    let pos = string.unicodeScalars.distance(from: string.unicodeScalars.startIndex, to: index)
    if pos != length - leastPaddingLength {
      print("string contains some invalid characters.")
      return nil
    }
  }

  var remainEncodedLength = length - leastPaddingLength
  var additionalBytes = 0
  switch remainEncodedLength % 8 {
  case 0: break
  case 2: additionalBytes = 1
  case 4: additionalBytes = 2
  case 5: additionalBytes = 3
  case 7: additionalBytes = 4
  default:
    print("string length is invalid.")
    return nil
  }

  let dataSize = remainEncodedLength / 8 * 5 + additionalBytes

  return string.utf8CString
    .withUnsafeBufferPointer { (data: UnsafeBufferPointer<CChar>) -> [UInt8] in
      var encoded = data.baseAddress!

      var result = [UInt8](repeating: 0, count: dataSize)
      var decodedOffset = 0

      var value0: UInt8
      var value1: UInt8
      var value2: UInt8
      var value3: UInt8
      var value4: UInt8
      var value5: UInt8
      var value6: UInt8
      var value7: UInt8
      (value0, value1, value2, value3, value4, value5, value6, value7) = (0, 0, 0, 0, 0, 0, 0, 0)
      while remainEncodedLength >= 8 {
        value0 = table[Int(encoded[0])]
        value1 = table[Int(encoded[1])]
        value2 = table[Int(encoded[2])]
        value3 = table[Int(encoded[3])]
        value4 = table[Int(encoded[4])]
        value5 = table[Int(encoded[5])]
        value6 = table[Int(encoded[6])]
        value7 = table[Int(encoded[7])]

        result[decodedOffset] = value0 << 3 | value1 >> 2
        result[decodedOffset + 1] = value1 << 6 | value2 << 1 | value3 >> 4
        result[decodedOffset + 2] = value3 << 4 | value4 >> 1
        result[decodedOffset + 3] = value4 << 7 | value5 << 2 | value6 >> 3
        result[decodedOffset + 4] = value6 << 5 | value7

        remainEncodedLength -= 8
        decodedOffset += 5
        encoded = encoded.advanced(by: 8)
      }

      (value0, value1, value2, value3, value4, value5, value6, value7) = (0, 0, 0, 0, 0, 0, 0, 0)
      switch remainEncodedLength {
      case 7:
        value6 = table[Int(encoded[6])]
        value5 = table[Int(encoded[5])]
        fallthrough
      case 5:
        value4 = table[Int(encoded[4])]
        fallthrough
      case 4:
        value3 = table[Int(encoded[3])]
        value2 = table[Int(encoded[2])]
        fallthrough
      case 2:
        value1 = table[Int(encoded[1])]
        value0 = table[Int(encoded[0])]
      default: break
      }
      switch remainEncodedLength {
      case 7:
        result[decodedOffset + 3] = value4 << 7 | value5 << 2 | value6 >> 3
        fallthrough
      case 5:
        result[decodedOffset + 2] = value3 << 4 | value4 >> 1
        fallthrough
      case 4:
        result[decodedOffset + 1] = value1 << 6 | value2 << 1 | value3 >> 4
        fallthrough
      case 2:
        result[decodedOffset] = value0 << 3 | value1 >> 2
      default: break
      }

      return result
    }
}

extension String {
  internal var dataUsingUTF8StringEncoding: Data {
    return utf8CString.withUnsafeBufferPointer {
      return Data($0.dropLast().map { UInt8.init($0) })
    }
  }

  internal var arrayUsingUTF8StringEncoding: [UInt8] {
    return utf8CString.withUnsafeBufferPointer {
      return $0.dropLast().map { UInt8.init($0) }
    }
  }
}
