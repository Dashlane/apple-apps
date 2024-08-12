import Foundation

public struct CryptoRawConfig: Equatable, Sendable, Hashable {
  public init(fixedSalt: Data?, marker: String) {
    self.fixedSalt = fixedSalt
    self.marker = marker
  }

  public var fixedSalt: Data?
  public let marker: String
}
