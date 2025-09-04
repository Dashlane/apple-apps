import CoreTypes
import Foundation
import LogFoundation
import SwiftTreats

public protocol Searchable {
  var searchValues: [SearchValueConvertible] { get }
  var id: Identifier { get }

  static var searchCategory: SearchCategory { get }
}

public protocol SearchValueConvertible {
  var searchValue: String? { get }
}

extension String: SearchValueConvertible {
  public var searchValue: String? {
    self
  }
}

extension Optional: SearchValueConvertible where Wrapped: SearchValueConvertible {
  public var searchValue: String? {
    self?.searchValue ?? nil
  }
}

public struct SearchMatch: Hashable {
  public enum Kind: Hashable {
    case startWith
    case contain
  }

  public enum Location: Hashable {
    case title
    case secondaryInfo(String)
  }

  public let kind: Kind
  public let location: Location
  public let category: SearchCategory
}

extension SearchMatch: Comparable {
  public static func < (lhs: SearchMatch, rhs: SearchMatch) -> Bool {
    switch (lhs.kind, rhs.kind) {
    case (.startWith, .contain):
      return true
    case (.contain, .startWith):
      return false
    default:
      if lhs.location == rhs.location {
        return lhs.category.priority < rhs.category.priority
      } else {
        return lhs.location == .title
      }
    }
  }
}

extension Searchable where Self: Displayable {
  public func match(_ searchCriteria: String) -> SearchMatch? {
    let options: String.CompareOptions = [
      .diacriticInsensitive, .caseInsensitive, .widthInsensitive,
    ]
    let title = displayTitle.lowercased()
    let objectId = id.rawValue
    let searchCriteria = searchCriteria.lowercased()

    if let result = title.match(
      searchCriteria, at: .title, options: options, searchCategory: Self.searchCategory)
    {
      return result
    }

    if let secondaryMatch = searchValues.lazy
      .compactMap({ value -> SearchMatch? in
        guard let value = value.searchValue?.lowercased() else {
          return nil
        }

        return value.match(
          searchCriteria,
          at: .secondaryInfo(value),
          options: options,
          searchCategory: Self.searchCategory)
      }).first
    {
      return secondaryMatch
    }

    if DiagnosticMode.isEnabled {
      if let result = objectId.lowercased().match(
        searchCriteria,
        at: .secondaryInfo(objectId),
        options: options,
        searchCategory: Self.searchCategory)
      {
        return result
      }
    }

    return nil
  }

}

extension Searchable where Self: PersonalDataCodable {
  public static var searchCategory: SearchCategory {
    return .credential
  }
}

extension String {
  fileprivate func match(
    _ searchCriteria: String,
    at location: SearchMatch.Location,
    options: String.CompareOptions, searchCategory: SearchCategory
  ) -> SearchMatch? {
    if self.hasPrefix(searchCriteria) {
      return SearchMatch(kind: .startWith, location: location, category: searchCategory)
    }
    if self.range(of: searchCriteria, options: options) != nil {
      return SearchMatch(kind: .contain, location: location, category: searchCategory)
    }
    return nil
  }
}
