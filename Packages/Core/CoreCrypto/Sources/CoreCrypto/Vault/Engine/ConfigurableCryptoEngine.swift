import CoreTypes
import Foundation
import SwiftTreats

public final class ConfigurableCryptoEngineImpl: ConfigurableCryptoEngine, @unchecked Sendable {
  @Atomic
  public private(set) var config: CoreTypes.CryptoRawConfig
  @Atomic
  public private(set) var parsedConfiguration: CryptoConfiguration

  public var displayedKeyDerivationInfo: String {
    switch parsedConfiguration {
    case let .flexible(config):
      switch config.derivation {
      case .pbkdf2(let pBKDF2Configuration):
        return "PBKDF2 \(pBKDF2Configuration.iterations / 1000)K"
      case .argon2d:
        return "Argon2d"
      case .none:
        return "No Derivation"
      }

    case .legacy(let legacyCryptoConfiguration):
      switch legacyCryptoConfiguration {
      case .kwc3:
        return "PBKDF2 10K"
      case .kwc5:
        return "No Derivation"
      }
    }
  }

  public let secret: EncryptionSecret
  private var engine: CryptoEngine

  public init(secret: EncryptionSecret, config: CoreTypes.CryptoRawConfig) throws {
    self.secret = secret
    self.config = config
    let parsedConfiguration = try CryptoConfiguration(rawConfigMarker: config.marker)
    self.parsedConfiguration = parsedConfiguration
    self.engine =
      try parsedConfiguration
      .makeCryptoEngine(secret: secret, fixedSalt: config.fixedSalt)
  }

  public init(secret: EncryptionSecret, encryptedData: Data) throws {
    self.secret = secret
    let parsedConfiguration = try CryptoConfiguration(encryptedData: encryptedData)
    self.parsedConfiguration = parsedConfiguration
    let salt = try? parsedConfiguration.derivationSalt(forEncryptedData: encryptedData)
    self.config = CryptoRawConfig(
      fixedSalt: salt, marker: try parsedConfiguration.rawConfigMarker())
    self.engine = try parsedConfiguration.makeCryptoEngine(secret: secret, fixedSalt: salt)
  }

  init(secret: EncryptionSecret, config: CryptoConfiguration, fixedSalt: Data? = nil) throws {
    self.secret = secret
    self.config = CryptoRawConfig(fixedSalt: fixedSalt, marker: try config.rawConfigMarker())
    let parsedConfiguration = config
    self.parsedConfiguration = parsedConfiguration
    self.engine =
      try parsedConfiguration
      .makeCryptoEngine(secret: secret, fixedSalt: fixedSalt)
  }

  public func update(to rawConfig: CoreTypes.CryptoRawConfig) throws {
    self.parsedConfiguration = try CryptoConfiguration(rawConfigMarker: rawConfig.marker)
    self.engine = try parsedConfiguration.makeCryptoEngine(
      secret: secret, fixedSalt: rawConfig.fixedSalt)
    self.config = rawConfig
  }

  public func encrypt(_ data: Data) throws -> Data {
    try engine.encrypt(data)
  }

  public func decrypt(_ data: Data) throws -> Data {
    try engine.decrypt(data)
  }
}
