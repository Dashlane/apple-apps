import Foundation

extension Definition {

  public enum `Highlight`: String, Encodable, Sendable {
    case `mostRecent` = "most_recent"
    case `none`
    case `searchRecent` = "search_recent"
    case `searchResult` = "search_result"
    case `suggested`
  }
}
