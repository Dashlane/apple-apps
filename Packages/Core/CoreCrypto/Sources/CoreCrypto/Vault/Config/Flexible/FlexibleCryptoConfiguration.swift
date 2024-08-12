import Foundation

public struct FlexibleCryptoConfiguration: Hashable, Sendable {
  static let markerSeperator = UInt8(ascii: "$")

  public enum KeyDerivationAlgorithm: Hashable, Sendable {
    case pbkdf2(PBKDF2Configuration)
    case argon2d(Argon2Configuration)

    var saltLength: Int {
      switch self {
      case let .pbkdf2(conf):
        conf.saltLength
      case let .argon2d(conf):
        conf.saltLength
      }
    }
  }

  fileprivate enum KeyDerivationAlgorithmKind: String, Equatable {
    case pbkdf2
    case argon2d
    case none = "noderivation"
  }

  public let version: Int
  public let derivation: KeyDerivationAlgorithm?
  public let encryption: EncryptionConfiguration
}
extension FlexibleCryptoConfiguration {
  public static let argon2d = FlexibleCryptoConfiguration(
    version: 1,
    derivation: .argon2d(.default),
    encryption: EncryptionConfiguration(
      encryptionAlgorithm: .aes256,
      cipherMode: .cbchmac,
      ivLength: 16))
  public static let pbkdf2 = FlexibleCryptoConfiguration(
    version: 1,
    derivation: .pbkdf2(.default),
    encryption: EncryptionConfiguration(
      encryptionAlgorithm: .aes256,
      cipherMode: .cbchmac,
      ivLength: 16))
  public static let noDerivation = FlexibleCryptoConfiguration(
    version: 1,
    derivation: nil,
    encryption: EncryptionConfiguration(
      encryptionAlgorithm: .aes256,
      cipherMode: .cbchmac64,
      ivLength: 16))

  public static let legacyNoDerivation = FlexibleCryptoConfiguration(
    version: 1,
    derivation: nil,
    encryption: EncryptionConfiguration(
      encryptionAlgorithm: .aes256,
      cipherMode: .cbchmac,
      ivLength: 16))
}

extension FlexibleCryptoConfiguration {
  public var saltLength: Int? {
    return derivation?.saltLength
  }

  public func derivationSalt(forEncryptedData data: Data) throws -> Data {
    guard let derivation else {
      throw CryptoEngineError.configCannotCreateDerivationSalt
    }

    let marker = try marker()
    return try data[safe: marker.endIndex..<marker.endIndex + derivation.saltLength]
  }
}

extension FlexibleCryptoConfiguration: FlexibleMarkerDecodable {
  init(decoder: inout FlexibleMarkerDecoder) throws {
    version = try decoder.decode(Int.self)
    guard version == 1 else {
      throw CryptoEngineError.unsupportedCryptoVersion(version)
    }

    let algorithm = try decoder.decode(KeyDerivationAlgorithmKind.self)

    switch algorithm {
    case .pbkdf2:
      derivation = .pbkdf2(try decoder.decode(PBKDF2Configuration.self))
    case .argon2d:
      derivation = .argon2d(try decoder.decode(Argon2Configuration.self))
    case .none:
      derivation = nil
    }

    encryption = try decoder.decode(EncryptionConfiguration.self)
  }
}

extension FlexibleCryptoConfiguration: FlexibleMarkerEncodable {
  func encode(to encoder: inout FlexibleMarkerEncoder) throws {
    try encoder.encode(version)
    switch derivation {
    case let .pbkdf2(conf):
      try encoder.encode(KeyDerivationAlgorithmKind.pbkdf2)
      try encoder.encode(conf)
    case let .argon2d(conf):
      try encoder.encode(KeyDerivationAlgorithmKind.argon2d)
      try encoder.encode(conf)
    case .none:
      try encoder.encode(KeyDerivationAlgorithmKind.none)
    }

    try encoder.encode(encryption)
  }
}
