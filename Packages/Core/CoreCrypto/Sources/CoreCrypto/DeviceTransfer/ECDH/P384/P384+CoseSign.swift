import CryptoKit
import Foundation
import SwiftTreats

extension P384.Signing.PublicKey {
  public init(x963RepresentationData publicKey: Data) throws {
    try self.init(x963Representation: publicKey.bytes)
  }

  public func isValidSignature(_ signature: Data, forCOSEPayload signedPayload: [UInt8]) throws
    -> Bool
  {
    let signatureForData = try P384.Signing.ECDSASignature.init(rawRepresentation: signature)
    let digest = SHA384.hash(data: signedPayload)
    return isValidSignature(signatureForData, for: digest)
  }
}
