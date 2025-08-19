import Foundation

extension Definition {

  public struct `Os`: Encodable, Sendable {
    public init(`locale`: String, `type`: Definition.OsType, `version`: String) {
      self.locale = locale
      self.type = type
      self.version = version
    }
    public let locale: String
    public let type: Definition.OsType
    public let version: String
  }
}
