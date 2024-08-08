import Foundation

public enum LegacyCryptoConfiguration: String, Sendable {
  case kwc3 = "KWC3"

  case kwc5 = "KWC5"
}

extension LegacyCryptoConfiguration {
  static let legacyMarkerPosition = 32
  static let legacyMarkerLength = 4

  public init?(rawConfigMarker: String) {
    self.init(rawValue: rawConfigMarker)
  }

  public init?(encryptedData: Data) {
    let markerPosition = Self.legacyMarkerPosition
    let markerOffset = markerPosition + Self.legacyMarkerLength

    guard encryptedData.count >= markerOffset else {
      return nil
    }

    let markerData = encryptedData[markerPosition..<markerOffset]
    guard let markerString = String(data: markerData, encoding: .utf8) else {
      return nil
    }
    self.init(rawValue: markerString)
  }
}

extension LegacyCryptoConfiguration {
  public var saltLength: Int? {
    switch self {
    case .kwc3:
      return PBKDF2Configuration.kwc3.saltLength
    case .kwc5:
      return nil
    }
  }

  public func derivationSalt(forEncryptedData data: Data) throws -> Data {
    switch self {
    case .kwc3:
      return try data[safe: ..<32]
    case .kwc5:
      throw CryptoEngineError.configCannotCreateDerivationSalt
    }
  }
}
