import Foundation

public struct Domain: Equatable, Codable {
  public let name: String
  public let publicSuffix: String?
  public var linkedDomains: [String]? {
    guard let index = Self.linkedDomains[name] else {
      return nil
    }

    return Self.linkedDomainsGroups[index]
  }

  public init(name: String, publicSuffix: String?) {
    self.name = name
    self.publicSuffix = publicSuffix
  }
}
