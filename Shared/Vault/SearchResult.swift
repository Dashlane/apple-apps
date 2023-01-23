import Foundation
import DashlaneReportKit
import DashlaneAppKit
import VaultKit

struct SearchResult {
    let searchCriteria: String
    let sections: [DataSection]
    
    var hasResult: Bool {
                return !sections.flatMap(\.items).isEmpty
    }
    
    var count: Int {
                return sections.reduce(0) { acc, section in
            return acc + section.items.count
        }
    }
}

extension SearchResult {
    func searchUsageLog(click: Bool = false, index: Int? = nil) -> UsageLogCode32Search {
        let nbKeywords = searchCriteria.split(separator: " ").count
        let nbCharacters = searchCriteria.replacingOccurrences(of: " ", with: "").count
        let nbResult = sections.reduce(0) { acc, section in
            return acc + section.items.count
        }
        return UsageLogCode32Search(keywords: nbKeywords,
                                    click: click,
                                    results: nbResult,
                                    characters: nbCharacters,
                                    position: index ?? 0)
    }
}
