import CryptoKit
import Foundation
import SwiftCBOR

public struct EC2PublicKey: PublicKey, Decodable, Equatable {
  public enum CodingKeys: Int, CodingKey {
    case type = 1
    case algorithm = 3
    case curve = -1
    case xCoordinate = -2
    case yCoordinate = -3

    var cbor: CBOR {
      CBOR(integerLiteral: rawValue)
    }
  }

  public let type: COSEKeyType

  public let algorithm: COSEAlgorithmIdentifier
  public let curve: COSECurve
  public let xCoordinate: Data
  public let yCoordinate: Data
  public var rawRepresentation: Data { xCoordinate + yCoordinate }

  init(algorithm: COSEAlgorithmIdentifier, curve: COSECurve, xCoordinate: Data, yCoordinate: Data) {
    self.algorithm = algorithm
    self.curve = curve
    self.xCoordinate = xCoordinate
    self.yCoordinate = yCoordinate
    self.type = .ellipticKey
  }

  public init?(rawCBOR: [UInt8]) throws {
    self = try CodableCBORDecoder().decode(EC2PublicKey.self, from: .init(rawCBOR))
  }
}

public typealias COSEKey = EC2PublicKey.CodingKeys

extension EC2PublicKey {
  public func cborByteArrayRepresentation() -> [UInt8] {
    let map = CBOR.orderedMap([
      (COSEKey.type.rawValue, CBOR.unsignedInt(COSEKeyType.ellipticKey.rawValue)),
      (COSEKey.algorithm.rawValue, CBOR(integerLiteral: algorithm.rawValue)),
      (COSEKey.curve.rawValue, CBOR.unsignedInt(curve.rawValue)),
      (COSEKey.xCoordinate.rawValue, CBOR.byteString([UInt8](xCoordinate))),
      (COSEKey.yCoordinate.rawValue, CBOR.byteString([UInt8](yCoordinate))),
    ])
    return map
  }
}

extension EC2PublicKey {
  public func isValidSignature(_ signature: Data, for digest: Data) throws -> Bool {
    switch algorithm {
    case .es256:
      let signature = try P256.Signing.ECDSASignature(derRepresentation: signature)
      return try P256.Signing.PublicKey(rawRepresentation: rawRepresentation)
        .isValidSignature(signature, for: digest)
    case .es384:
      let signature = try P384.Signing.ECDSASignature(derRepresentation: signature)
      return try P384.Signing.PublicKey(rawRepresentation: rawRepresentation)
        .isValidSignature(signature, for: digest)
    case .es512:
      let signature = try P521.Signing.ECDSASignature(derRepresentation: signature)
      return try P521.Signing.PublicKey(rawRepresentation: rawRepresentation)
        .isValidSignature(signature, for: digest)
    }
  }
}
