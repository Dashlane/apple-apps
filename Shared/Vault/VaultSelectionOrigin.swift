import Foundation
import CoreUserTracking

enum VaultSelectionOrigin {
    case searchResult
    case regularList
    case suggestedItems
    case recentSearch
    
    var definitionHighlight: Definition.Highlight {
        switch self {
        case .suggestedItems:
            return .suggested
        case .searchResult:
            return .searchResult
        case .recentSearch:
            return .searchRecent
        default:
            return .none
        }
    }
}
