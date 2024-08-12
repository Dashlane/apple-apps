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
  static var curve: JWK.Curve { get }
  associatedtype PublicKey: SigningCurvePublicKey
  var rawRepresentation: Data { get }
  var publicKey: PublicKey { get }

  init<D>(x963Representation: D) throws where D: ContiguousBytes
}

extension P256.Signing.PrivateKey: SigningCurvePrivateKey {
  public static var curve: JWK.Curve {
    return .p256
  }
}

extension P384.Signing.PrivateKey: SigningCurvePrivateKey {
  public static var curve: JWK.Curve {
    return .p384
  }
}

extension P521.Signing.PrivateKey: SigningCurvePrivateKey {
  public static var curve: JWK.Curve {
    return .p521
  }
}

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

extension SigningCurvePrivateKey {
  public init(jwk: JWK) throws {
    guard let params = jwk.decodeParameters(), Self.curve == jwk.crv else {
      throw CryptoKitError.incorrectParameterSize
    }

    try self.init(x963Representation: Data([0x04] + params.x + params.y + params.d))
  }

  public func jwk() -> JWK {
    let coordinates = publicKey.coordinates

    return JWK(
      ext: true,
      keyOps: ["sign"],
      kty: .ecdsa,
      crv: Self.curve,
      parameters: .init(x: coordinates.x, y: coordinates.y, d: rawRepresentation))
  }
}
