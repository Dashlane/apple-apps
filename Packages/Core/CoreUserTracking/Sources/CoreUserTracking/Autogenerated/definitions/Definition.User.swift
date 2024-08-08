import Foundation

extension Definition {

  public struct `User`: Encodable, Sendable {
    public init(`id`: LowercasedUUID) {
      self.id = id
    }
    public let id: LowercasedUUID
  }
}
