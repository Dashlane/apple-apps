import Foundation

extension Definition {

  public enum `CryptoAlgorithm`: String, Encodable, Sendable {
    case `argon2D` = "argon2d"
    case `kwc3`
    case `kwc5`
    case `noDerivation` = "no_derivation"
    case `pbkdf2`
  }
}
