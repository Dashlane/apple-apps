import Foundation
import SwiftCBOR

extension CBOR {
  static func orderedMap(_ content: [(key: CBOREncodable, value: CBOR)]) -> [UInt8] {
    var result: [UInt8] = content.count.encode()
    result.reserveCapacity(content.count)
    result[0] = result[0] | 0b1010_0000

    content.forEach { (key, value) in
      result.append(contentsOf: key.encode(options: .init()))
      result.append(contentsOf: value.encode())
    }
    return result
  }
}
