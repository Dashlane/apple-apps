import CyrilKit
import Foundation

public struct PBKDF2Configuration: Hashable, Sendable {
  public enum HashAlgorithm: String, Sendable {
    case sha1 = "sha1"
    case sha224 = "sha224"
    case sha256 = "sha256"
    case sha384 = "sha384"
    case sha512 = "sha512"
  }

  public let saltLength: Int
  public let iterations: Int
  public let hashAlgorithm: HashAlgorithm
}

extension PBKDF2Configuration: FlexibleMarkerDecodable {
  init(decoder: inout FlexibleMarkerDecoder) throws {
    saltLength = try decoder.decode(Int.self)
    iterations = try decoder.decode(Int.self)
    hashAlgorithm = try decoder.decode(HashAlgorithm.self)
  }
}

extension PBKDF2Configuration: FlexibleMarkerEncodable {
  func encode(to encoder: inout FlexibleMarkerEncoder) throws {
    try encoder.encode(saltLength)
    try encoder.encode(iterations)
    try encoder.encode(hashAlgorithm)
  }
}

extension PBKDF2 {
  init(configuration: PBKDF2Configuration, derivedKeyLength: Int) {
    self.init(
      algorithm: Algorithm(configuration.hashAlgorithm),
      derivedKeyLength: derivedKeyLength,
      numberOfIterations: UInt32(configuration.iterations))
  }
}

extension PBKDF2.Algorithm {
  init(_ algorithm: PBKDF2Configuration.HashAlgorithm) {
    switch algorithm {
    case .sha1:
      self = .sha1
    case .sha224:
      self = .sha224
    case .sha256:
      self = .sha256
    case .sha384:
      self = .sha384
    case .sha512:
      self = .sha512
    }
  }
}
