import Foundation

extension Definition {

  public struct `Device`: Encodable, Sendable {
    public init(`id`: LowercasedUUID? = nil, `installationId`: LowercasedUUID, `os`: Definition.Os)
    {
      self.id = id
      self.installationId = installationId
      self.os = os
    }
    public let id: LowercasedUUID?
    public let installationId: LowercasedUUID
    public let os: Definition.Os
  }
}
