import CryptoKit
import Foundation
import SwiftCBOR

public struct EC2PublicKey: PublicKey {
  public let algorithm: COSEAlgorithmIdentifier
  let curve: COSECurve
  let xCoordinate: Data
  let yCoordinate: Data
  var rawRepresentation: Data { xCoordinate + yCoordinate }

  init(algorithm: COSEAlgorithmIdentifier, curve: COSECurve, xCoordinate: Data, yCoordinate: Data) {
    self.algorithm = algorithm
    self.curve = curve
    self.xCoordinate = xCoordinate
    self.yCoordinate = yCoordinate
  }
}

extension EC2PublicKey {
  public func cborByteArrayRepresentation() -> [UInt8] {
    let map = CBOR.orderedMap([
      (COSEKey.kty.rawValue, CBOR.unsignedInt(COSEKeyType.ellipticKey.rawValue)),
      (COSEKey.alg.rawValue, CBOR(integerLiteral: algorithm.rawValue)),
      (COSEKey.crv.rawValue, CBOR.unsignedInt(curve.rawValue)),
      (COSEKey.x.rawValue, CBOR.byteString([UInt8](xCoordinate))),
      (COSEKey.y.rawValue, CBOR.byteString([UInt8](yCoordinate))),
    ])
    return map
  }
}
