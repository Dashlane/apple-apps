import CryptoKit
import Foundation

public protocol SigningCurvePublicKey {
  var rawRepresentation: Data { get }
  init<D>(rawRepresentation: D) throws where D: ContiguousBytes
}

extension P256.Signing.PublicKey: SigningCurvePublicKey {}
extension P384.Signing.PublicKey: SigningCurvePublicKey {}
extension P521.Signing.PublicKey: SigningCurvePublicKey {}

public protocol SigningCurvePrivateKey {
  associatedtype PublicKey: SigningCurvePublicKey
  var rawRepresentation: Data { get }
  var publicKey: PublicKey { get }

  init<D>(x963Representation: D) throws where D: ContiguousBytes
}

extension P256.Signing.PrivateKey: SigningCurvePrivateKey {}
extension P384.Signing.PrivateKey: SigningCurvePrivateKey {}
extension P521.Signing.PrivateKey: SigningCurvePrivateKey {}

extension SigningCurvePublicKey {
  init(x: Data, y: Data) throws {
    try self.init(rawRepresentation: x + y)
  }

  var coordinates: (x: Data, y: Data) {
    let data = rawRepresentation
    let half = data.count / 2
    let midIndex = data.index(data.startIndex, offsetBy: half)
    let x = data[..<midIndex]
    let y = data[midIndex...]

    return (x: x, y: y)
  }
}
