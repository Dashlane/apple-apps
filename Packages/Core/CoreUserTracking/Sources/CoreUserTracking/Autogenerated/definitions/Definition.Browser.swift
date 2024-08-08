import Foundation

extension Definition {

  public struct `Browser`: Encodable, Sendable {
    public init(`name`: String, `userAgent`: String, `version`: String? = nil) {
      self.name = name
      self.userAgent = userAgent
      self.version = version
    }
    public let name: String
    public let userAgent: String
    public let version: String?
  }
}
