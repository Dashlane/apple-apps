import CyrilKit
import Foundation

public struct Argon2Configuration: Hashable, Sendable {
  public let saltLength: Int
  public let timeCost: Int
  public let memoryCost: Int
  public let parallelism: Int

}

extension Argon2Configuration {
  public static let `default` = Argon2Configuration(
    saltLength: 16,
    timeCost: 3,
    memoryCost: 32768,
    parallelism: 2)
}

extension Argon2Configuration: FlexibleMarkerDecodable {
  init(decoder: inout FlexibleMarkerDecoder) throws {
    saltLength = try decoder.decode(Int.self)
    timeCost = try decoder.decode(Int.self)
    memoryCost = try decoder.decode(Int.self)
    parallelism = try decoder.decode(Int.self)
  }
}

extension Argon2Configuration: FlexibleMarkerEncodable {
  func encode(to encoder: inout FlexibleMarkerEncoder) throws {
    try encoder.encode(saltLength)
    try encoder.encode(timeCost)
    try encoder.encode(memoryCost)
    try encoder.encode(parallelism)
  }
}

extension Argon2d {
  init(configuration: Argon2Configuration, derivedKeyLength: Int) {
    self.init(
      timeCost: UInt32(configuration.timeCost),
      memoryCost: UInt32(configuration.memoryCost),
      parallelism: UInt32(configuration.parallelism),
      derivedKeyLength: derivedKeyLength)
  }
}
