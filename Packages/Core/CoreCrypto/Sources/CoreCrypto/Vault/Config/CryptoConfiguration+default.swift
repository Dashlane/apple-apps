import CoreTypes
import Foundation

extension CryptoConfiguration {
  public static let `default` = CryptoConfiguration.flexible(.argon2d)

  public static let defaultNoDerivation = CryptoConfiguration.flexible(.noDerivation)
  public static let legacyNoDerivation = CryptoConfiguration.flexible(.legacyNoDerivation)

  public static let local = defaultNoDerivation

  public static let sso = defaultNoDerivation

  public static let file = CryptoConfiguration.flexible(
    FlexibleCryptoConfiguration(
      version: 1,
      derivation: nil,
      encryption: EncryptionConfiguration(
        encryptionAlgorithm: .aes256,
        cipherMode: .cbchmac,
        ivLength: 16)))

  public static let sharing = CryptoConfiguration.legacy(.kwc5)
}

extension CryptoRawConfig {
  public static let masterPasswordBasedDefault = try! CryptoRawConfig(.default)
  public static let noDerivationDefault = try! CryptoRawConfig(.defaultNoDerivation)
  public static let legacyNoDerivation = try! CryptoRawConfig(.legacyNoDerivation)
  init(_ configuration: CryptoConfiguration) throws {
    self.init(
      fixedSalt: try? configuration.makeDerivationSalt(),
      marker: try configuration.rawConfigMarker())
  }
}
