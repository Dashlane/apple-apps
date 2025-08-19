import Combine
import CoreLocalization
import CorePersonalData
import CorePremium
import CoreSpotlight
import CoreTeamAuditLogs
import DashlaneAPI
import Foundation
import SwiftUI

extension VaultItem {
  public var addTitle: String {
    return Self.addTitle
  }

  public var limitedRightsAlertTitle: String {
    switch vaultItemType {
    case .credential:
      return CoreL10n.kwLimitedRightMessage
    case .secureNote:
      return CoreL10n.kwSecureNoteLimitedRightMessage
    default:
      return ""
    }
  }

  public func isAssociated(to: PremiumStatusTeamInfo) -> Bool {
    return false
  }
}

extension VaultItem {
  public func generateReportableInfo(with context: AuditLogContext) -> ReportableInfo? {
    return nil
  }
}

extension VaultItem where Self: Searchable {
  public func matchCriteria(_ criteria: String) -> SearchMatch? {
    return match(criteria)
  }
}

extension Array where Element == VaultItem {
  public func filterAndSortItemsUsingCriteria(_ criteria: String) -> [Element] {
    return self.compactMap { item -> (item: VaultItem, ranking: SearchMatch)? in
      guard let ranking: SearchMatch = item.matchCriteria(criteria) else { return nil }
      return (item, ranking)
    }
    .sorted { $0.ranking < $1.ranking }
    .map(\.item)
  }
}

extension Array where Element: VaultItem {

  public func filterAndSortItemsUsingCriteria(_ criteria: String) -> [Element] {
    return filterAndSortItems(self, criteria: criteria)
  }

  private func filterAndSortItems<Item: VaultItem>(_ items: [Item], criteria: String) -> [Item] {
    return items.compactMap { item -> (item: Item, ranking: SearchMatch)? in
      guard let ranking: SearchMatch = item.matchCriteria(criteria) else { return nil }
      return (item, ranking)
    }
    .sorted { $0.ranking < $1.ranking }
    .map(\.item)
  }
}

extension Array where Element == DataSection {
  public func filterAndSortItemsUsingCriteria(_ criteria: String) -> [DataSection] {
    return self.map {
      DataSection(
        name: $0.name, listIndex: $0.listIndex,
        items: $0.items.filterAndSortItemsUsingCriteria(criteria))
    }
  }
}

extension Collection where Element: VaultItem {
  public func alphabeticallyGrouped() -> [DataSection] {
    return Dictionary(grouping: self) { credential in
      guard let first = credential.localizedTitle.first, first.isAllowedForIndexation else {
        return "#"
      }
      return String(first).uppercased()
    }.map {
      DataSection(name: $0.key, items: $0.value.alphabeticallySorted())
    }.sorted {
      $0.name < $1.name
    }
  }
}

extension Collection where Element: VaultItem {
  public func alphabeticallySorted() -> [Element] {
    self.sorted { (right, left) -> Bool in
      return right.localizedTitle.lowercased() < left.localizedTitle.lowercased()
    }
  }
}

extension Collection where Element == VaultItem {
  public func alphabeticallyGrouped() -> [DataSection] {
    return Dictionary(grouping: self) { credential in
      guard let first = credential.localizedTitle.first, first.isAllowedForIndexation else {
        return "#"
      }
      return String(first).uppercased()
    }.map {
      DataSection(name: $0.key, items: $0.value.alphabeticallySorted())
    }.sorted {
      $0.name < $1.name
    }
  }
}

extension Collection where Element == VaultItem {
  public func alphabeticallySorted() -> [Element] {
    self.sorted { (right, left) -> Bool in
      return right.localizedTitle.lowercased() < left.localizedTitle.lowercased()
    }
  }
}
