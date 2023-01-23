import Foundation
import VaultKit

extension Array where Element == VaultItem {
        func suggestedItems() -> [VaultItem] {
        let allItems = Dictionary(grouping: self) { $0.metadata.lastLocalUseDate == nil }
        let suggestedItems = allItems[false] ?? []
        let otherItems = allItems[true] ?? []
        return suggestedItems.sortedByUsageDate() + otherItems.sortedByDate()
    }

        private func sortedByUsageDate() -> [VaultItem] {
        return self
            .sorted { item1, item2 in
                guard let date1 = item1.metadata.lastLocalUseDate,
                      let date2 = item2.metadata.lastLocalUseDate
                else { return false }
                return date1 > date2
            }
    }

        private func sortedByDate() -> [VaultItem] {
        let now = Date().addingTimeInterval(60) 
        return self
            .filter {
                guard let date = $0.sortingDate else { return false }
                return date < now
            }
            .sorted { item1, item2 in
                guard let date1 = item1.sortingDate,
                      let date2 = item2.sortingDate else {
                    assertionFailure("Item hasn't got any creation or modification date")
                    return false
                }
                return date1 > date2
            }
    }
}
