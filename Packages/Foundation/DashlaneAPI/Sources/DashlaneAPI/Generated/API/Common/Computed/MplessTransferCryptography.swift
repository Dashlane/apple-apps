import Foundation

public struct MplessTransferCryptography: Codable, Equatable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case algorithm = "algorithm"
    case ellipticCurve = "ellipticCurve"
  }

  public let algorithm: MplessTransferAlgorithm
  public let ellipticCurve: MplessTransferEllipticCurve

  public init(algorithm: MplessTransferAlgorithm, ellipticCurve: MplessTransferEllipticCurve) {
    self.algorithm = algorithm
    self.ellipticCurve = ellipticCurve
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(algorithm, forKey: .algorithm)
    try container.encode(ellipticCurve, forKey: .ellipticCurve)
  }
}
