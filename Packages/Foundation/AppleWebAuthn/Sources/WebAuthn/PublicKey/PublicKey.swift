import Foundation

public protocol PublicKey {
  var algorithm: COSEAlgorithmIdentifier { get }
  func cborByteArrayRepresentation() -> [UInt8]
}
