import CyrilKit
import Foundation
import LogFoundation

import struct CryptoKit.SHA512
import struct CryptoKit.SymmetricKey

@Loggable
public struct EncryptionConfiguration: Hashable, Sendable {
  @Loggable
  public enum AESMode: String, Sendable {
    case cbchmac

    case cbchmac64
  }

  @Loggable
  public enum EncryptionAlgorithm: String, Sendable {
    case aes256
  }

  public let encryptionAlgorithm: EncryptionAlgorithm
  public let cipherMode: AESMode
  public let ivLength: Int
}

extension EncryptionConfiguration: FlexibleMarkerDecodable {
  init(decoder: inout FlexibleMarkerDecoder) throws {
    encryptionAlgorithm = try decoder.decode(EncryptionAlgorithm.self)
    cipherMode = try decoder.decode(AESMode.self)
    ivLength = try decoder.decode(Int.self)
  }
}

extension EncryptionConfiguration: FlexibleMarkerEncodable {
  func encode(to encoder: inout FlexibleMarkerEncoder) throws {
    try encoder.encode(encryptionAlgorithm)
    try encoder.encode(cipherMode)
    try encoder.encode(ivLength)
  }
}

typealias EncryptedDataKey = CyrilKit.SymmetricKey
typealias HMACKey = CryptoKit.SymmetricKey

extension EncryptionConfiguration.AESMode {
  var supportedKeySizes: Set<Int> {
    switch self {
    case .cbchmac:
      return [16, 32, 64]
    case .cbchmac64:
      return [64]
    }
  }

  var defaultKeySize: Int {
    switch self {
    case .cbchmac:
      return 32
    case .cbchmac64:
      return 64
    }
  }

  func keys(from key: CyrilKit.SymmetricKey) throws -> (
    hmacKey: HMACKey, encryptedDataKey: EncryptedDataKey
  ) {
    let encryptionKey: EncryptedDataKey
    let hmacKey: HMACKey

    switch self {
    case .cbchmac:
      (hmacKey, encryptionKey) = key.expandKeysUsingHash()

    case .cbchmac64:
      encryptionKey = key[..<32]
      hmacKey = .init(data: key[32...])
    }

    return (hmacKey, encryptionKey)
  }
}

extension CyrilKit.SymmetricKey {
  func expandKeysUsingHash() -> (hmacKey: HMACKey, encryptedDataKey: EncryptedDataKey) {
    let sha512 = Data(SHA512.hash(data: self))
    let encryptedDataKey = sha512[..<32]
    let hmacKey = sha512[32...]
    return (.init(data: hmacKey), encryptedDataKey)
  }
}
