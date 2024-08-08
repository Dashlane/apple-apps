import Foundation

public enum CryptoConfiguration: Hashable, Sendable {
  case flexible(FlexibleCryptoConfiguration)
  case legacy(LegacyCryptoConfiguration)
}

extension CryptoConfiguration {
  public init(rawConfigMarker: String) throws {
    do {
      self = .flexible(try FlexibleCryptoConfiguration(rawConfigMarker: rawConfigMarker))
    } catch {
      if let legacyConfiguration = LegacyCryptoConfiguration(rawConfigMarker: rawConfigMarker) {
        self = .legacy(legacyConfiguration)
      } else {
        throw error
      }
    }
  }

  public init(encryptedData: Data) throws {
    do {
      self = .flexible(try FlexibleCryptoConfiguration(encryptedData: encryptedData))
    } catch {
      if let legacyConfiguration = LegacyCryptoConfiguration(encryptedData: encryptedData) {
        self = .legacy(legacyConfiguration)
      } else {
        throw error
      }
    }
  }

  public func rawConfigMarker() throws -> String {
    switch self {
    case .flexible(let flexibleCryptoConfiguration):
      return try flexibleCryptoConfiguration.rawConfigMarker()
    case .legacy(let legacyConfiguration):
      return legacyConfiguration.rawValue
    }
  }
}

extension CryptoConfiguration {
  public var saltLength: Int? {
    switch self {
    case .flexible(let flexibleCryptoConfiguration):
      return flexibleCryptoConfiguration.saltLength
    case .legacy(let legacyCryptoConfiguration):
      return legacyCryptoConfiguration.saltLength
    }
  }

  public func makeDerivationSalt() throws -> Data {
    guard let saltLength else {
      throw CryptoEngineError.configCannotCreateDerivationSalt
    }

    return Data.random(ofSize: saltLength)
  }

  public func derivationSalt(forEncryptedData data: Data) throws -> Data {
    switch self {
    case .flexible(let flexibleCryptoConfiguration):
      try flexibleCryptoConfiguration.derivationSalt(forEncryptedData: data)
    case .legacy(let legacyCryptoConfiguration):
      try legacyCryptoConfiguration.derivationSalt(forEncryptedData: data)
    }
  }
}
