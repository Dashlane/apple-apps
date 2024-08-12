import SwiftCBOR

enum COSEKey: Int {
  case kty = 1
  case alg = 3
  case crv = -1
  case x = -2
  case y = -3

  var cbor: CBOR {
    let value = self.rawValue
    if value < 0 {
      return .negativeInt(UInt64(abs(-1 - value)))
    } else {
      return .unsignedInt(UInt64(value))
    }
  }
}
