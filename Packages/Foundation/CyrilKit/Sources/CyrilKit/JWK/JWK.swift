import Foundation

public struct JWK: Codable, Equatable {
  public enum KeyType: String, Codable {
    case rsa = "RSA"
    case ecdsa = "EC"
    case octetKeyPair = "OKP"
  }

  public enum Curve: String, Codable {
    case p256 = "P-256"
    case p384 = "P-384"
    case p521 = "P-521"
    case ed25519 = "Ed25519"
    case ed448 = "Ed448"
  }

  public let ext: Bool?
  public let keyOps: [String]
  public let kty: KeyType?
  public let crv: Curve?
  public var d: String
  public var x: String
  public var y: String

  enum CodingKeys: String, CodingKey {
    case ext
    case keyOps = "key_ops"
    case d
    case x
    case kty
    case y
    case crv
  }

  public init(
    ext: Bool,
    keyOps: [String],
    kty: KeyType,
    crv: Curve?,
    d: String,
    x: String,
    y: String
  ) {
    self.ext = ext
    self.keyOps = keyOps
    self.kty = kty
    self.crv = crv
    self.d = d
    self.x = x
    self.y = y
  }
}

extension JWK {
  public struct Parameters {
    let x: Data
    let y: Data
    let d: Data
  }

  public init(
    ext: Bool,
    keyOps: [String],
    kty: KeyType,
    crv: Curve?,
    parameters: Parameters
  ) {
    self.ext = ext
    self.keyOps = keyOps
    self.kty = kty
    self.crv = crv
    self.d = parameters.d.base64URLEncoded()
    self.x = parameters.x.base64URLEncoded()
    self.y = parameters.y.base64URLEncoded()
  }

  public func decodeParameters() -> Parameters? {
    guard let x = Data(base64URLEncoded: x),
      let y = Data(base64URLEncoded: y),
      let d = Data(base64URLEncoded: d)
    else {
      return nil
    }

    return Parameters(x: x, y: y, d: d)
  }
}
