import CyrilKit
import Foundation

struct KeyDerivation {
  typealias Salt = Data

  let password: Data
  let fixedSalt: Salt?
  let saltLength: Int
  let fixedDerivedKey: SymmetricKey?
  let function: DerivationFunction
  let algorithm: FlexibleCryptoConfiguration.KeyDerivationAlgorithm

  init(
    password: String,
    fixedSalt: Salt?,
    algorithm: FlexibleCryptoConfiguration.KeyDerivationAlgorithm,
    derivedKeyLength: Int
  ) throws {
    guard let data = password.data(using: .utf8, allowLossyConversion: true) else {
      throw CryptoEngineError.passwordEncodingFailure(encoding: .utf8)
    }

    try self.init(
      password: data,
      fixedSalt: fixedSalt,
      algorithm: algorithm,
      derivedKeyLength: derivedKeyLength)
  }

  init(
    password: Data,
    fixedSalt: Data?,
    algorithm: FlexibleCryptoConfiguration.KeyDerivationAlgorithm,
    derivedKeyLength: Int
  ) throws {

    self.password = password.last == 0 ? password[..<(password.endIndex - 1)] : password
    self.fixedSalt = fixedSalt
    self.algorithm = algorithm

    switch algorithm {
    case .pbkdf2(let configuration):
      self.function = PBKDF2(configuration: configuration, derivedKeyLength: derivedKeyLength)
      self.saltLength = configuration.saltLength

    case .argon2d(let configuration):
      self.function = Argon2d(configuration: configuration, derivedKeyLength: derivedKeyLength)
      self.saltLength = configuration.saltLength
    }

    if let fixedSalt, fixedSalt.count >= saltLength {
      let fixedSalt = fixedSalt.prefix(saltLength)
      fixedDerivedKey = try function.derivateKey(from: password, salt: fixedSalt)
      cache[fixedSalt] = fixedDerivedKey
    } else {
      fixedDerivedKey = nil
    }
  }

  func makeSalt() -> Data {
    if let fixedSalt, fixedSalt.count == saltLength {
      return fixedSalt
    } else {
      return Data.random(ofSize: saltLength)
    }
  }

  func key(usingSalt salt: Data) throws -> SymmetricKey {
    if fixedSalt == salt, let fixedDerivedKey {
      return fixedDerivedKey
    } else {
      if let derivedKey = cache[salt] {
        return derivedKey
      } else {
        let derivedKey = try function.derivateKey(from: password, salt: salt)
        cache[salt] = derivedKey
        return derivedKey
      }
    }
  }
}

extension KeyDerivation {
  struct ThreadCache {
    private struct Key: Hashable {
      let algorithm: FlexibleCryptoConfiguration.KeyDerivationAlgorithm
      let salt: Data
      let password: Data
    }

    let algorithm: FlexibleCryptoConfiguration.KeyDerivationAlgorithm
    let password: Data

    subscript(salt: Data) -> SymmetricKey? {
      get {
        let cacheKey = Key(
          algorithm: algorithm,
          salt: salt,
          password: password)
        return Thread.current.threadDictionary[cacheKey] as? SymmetricKey
      }
      nonmutating set {
        let cacheKey = Key(
          algorithm: algorithm,
          salt: salt,
          password: password)
        Thread.current.threadDictionary[cacheKey] = newValue
      }
    }
  }

  var cache: ThreadCache {
    return .init(algorithm: algorithm, password: password)
  }
}
