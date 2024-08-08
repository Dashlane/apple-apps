import Foundation

public protocol DerivationFunction {
  var derivedKeyLength: Int { get }

  func derivateKey<V: ContiguousBytes, S: ContiguousBytes>(from password: V, salt: S) throws -> Data
}

enum KeyDerivaterError: Error {
  case stringToCStringFailed
  case derivationFailed(internalError: Error)
}

extension DerivationFunction {
  public func derivateKey(from password: String, salt: Data, encoding: String.Encoding = .utf8)
    throws -> Data
  {
    guard var passwordBytes = password.data(using: encoding) else {
      throw KeyDerivaterError.stringToCStringFailed
    }

    if passwordBytes.last == 0 {
      passwordBytes.removeLast()
    }
    return try derivateKey(from: passwordBytes, salt: salt)
  }
}
