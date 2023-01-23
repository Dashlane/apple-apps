import Foundation
import CryptoKit
import SwiftTreats

public extension P384.Signing.PublicKey {
    init(x963RepresentationData publicKey: Data) throws {
        try self.init(x963Representation: publicKey.bytes)
    }
    
    func isValidSignature(_ signature: Data, forCOSEPayload signedPayload: [UInt8]) throws -> Bool {
        let signatureForData = try P384.Signing.ECDSASignature.init(rawRepresentation: signature)
        let digest = SHA384.hash(data: signedPayload)
        return isValidSignature(signatureForData, for: digest)
    }
}
