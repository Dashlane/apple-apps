import CorePersonalData
import Foundation

extension Array where Element == DataSection {
  public func addingSuggestedSection(suggestedItemsMaxCount: Int = 6, name: String) -> [DataSection]
  {
    var allSections = self
    let allItems = self.flatMap(\.items)
    if allItems.count > suggestedItemsMaxCount {
      let suggestedItems =
        allItems
        .suggestedItems(suggestedItemsMaxCount: suggestedItemsMaxCount)

      let suggestedSection = DataSection(
        name: name,
        type: .suggestedItems,
        items: suggestedItems
      )
      allSections = [suggestedSection] + allSections
    }
    return allSections
  }
}

extension Array where Element == VaultItem {
  public func suggestedItems(suggestedItemsMaxCount: Int) -> [VaultItem] {
    let allItems = Dictionary(grouping: self) { $0.metadata.lastLocalUseDate == nil }
    let suggestedItems = allItems[false] ?? []
    let otherItems = allItems[true] ?? []
    guard suggestedItems.count >= suggestedItemsMaxCount else {
      let items = suggestedItems.sortedByUsageDate() + otherItems.sortedByDate()
      return Array(items.prefix(suggestedItemsMaxCount))
    }
    return Array(suggestedItems.sortedByUsageDate().prefix(suggestedItemsMaxCount))
  }

  private func sortedByUsageDate() -> [VaultItem] {
    return
      self
      .sorted { item1, item2 in
        guard let date1 = item1.metadata.lastLocalUseDate,
          let date2 = item2.metadata.lastLocalUseDate
        else { return false }
        return date1 > date2
      }
  }

  private func sortedByDate() -> [VaultItem] {
    let now = Date().addingTimeInterval(60)
    return
      self
      .filter {
        guard let date = $0.sortingDate else { return false }
        return date < now
      }
      .sorted { item1, item2 in
        guard let date1 = item1.sortingDate,
          let date2 = item2.sortingDate
        else {
          assertionFailure("Item hasn't got any creation or modification date")
          return false
        }
        return date1 > date2
      }
  }
}
