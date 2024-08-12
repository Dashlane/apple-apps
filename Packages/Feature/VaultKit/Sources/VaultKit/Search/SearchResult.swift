import Foundation

public struct SearchResult {
  public let searchCriteria: String
  public let sections: [DataSection]

  public init(searchCriteria: String, sections: [DataSection]) {
    self.searchCriteria = searchCriteria
    self.sections = sections
  }

  public func hasResult() -> Bool {
    return !sections.flatMap(\.items).isEmpty
  }

  public func count() -> Int {
    return sections.reduce(0) { acc, section in
      return acc + section.items.count
    }
  }
}
