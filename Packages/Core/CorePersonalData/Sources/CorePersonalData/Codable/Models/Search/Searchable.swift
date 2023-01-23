import Foundation


public protocol Searchable {
        var searchableKeyPaths: [KeyPath<Self, String>] { get }
    
        static var searchCategory: SearchCategory { get }
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

public extension Searchable where Self: Displayable {
    func match(_ searchCriteria: String) -> SearchMatch? {
        let options: String.CompareOptions = [.diacriticInsensitive, .caseInsensitive, .widthInsensitive]
        let title = displayTitle.lowercased()
        let searchCriteria = searchCriteria.lowercased()
        
                if title.hasPrefix(searchCriteria) {
            return SearchMatch(kind: .startWith, location: .title, category: Self.searchCategory)
        }
        
                if title.range(of: searchCriteria, options: options) != nil {
            return SearchMatch(kind: .contain, location: .title, category: Self.searchCategory)
        }

        for keyPath in searchableKeyPaths {
            let value = self[keyPath: keyPath]
            
                        if value.lowercased().hasPrefix(searchCriteria) {
                return SearchMatch(kind: .startWith, location: .secondaryInfo(value), category: Self.searchCategory)
            }
            
                        if value.range(of: searchCriteria, options: options) != nil {
                return SearchMatch(kind: .contain, location: .secondaryInfo(value), category: Self.searchCategory)
            }
        }

        return nil
    }

}
