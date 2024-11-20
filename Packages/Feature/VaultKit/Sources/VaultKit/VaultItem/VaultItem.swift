import Combine
import CoreActivityLogs
import CoreLocalization
import CorePersonalData
import CorePremium
import CoreSpotlight
import DashlaneAPI
import Foundation
import SwiftUI

public protocol VaultItem: CorePersonalData.Displayable,
  CorePersonalData.DatedPersonalData,
  CorePersonalData.DocumentAttachable,
  CoreActivityLogs.ActivityLogReportableItem
{
  static var localizedName: String { get }
  static var addIcon: SwiftUI.Image { get }
  static var addTitle: String { get }
  static var nativeMenuAddTitle: String { get }

  var enumerated: VaultItemEnumeration { get }

  var localizedTitle: String { get }
  var localizedSubtitle: String { get }

  var listIcon: VaultItemIcon { get }
  var icon: VaultItemIcon { get }
  var subtitleImage: SwiftUI.Image? { get }
  var subtitleFont: Font? { get }

  var creationDatetime: Date? { get set }
  var userModificationDatetime: Date? { get set }

  var spaceId: String? { get set }

  var limitedRightsAlertTitle: String { get }

  init()

  func matchCriteria(_ criteria: String) -> SearchMatch?

  func isAssociated(to: PremiumStatusTeamInfo) -> Bool
}

extension VaultItem {
  public var displayTitle: String {
    localizedTitle
  }

  public var displaySubtitle: String? {
    localizedSubtitle
  }

  public var subtitleImage: SwiftUI.Image? {
    return nil
  }

  public var subtitleFont: Font? {
    return nil
  }
}

extension VaultItem {
  public var listIcon: VaultItemIcon {
    return icon
  }

  public var addTitle: String {
    return Self.addTitle
  }

  public var limitedRightsAlertTitle: String {
    switch vaultItemType {
    case .credential:
      return CoreLocalization.L10n.Core.kwLimitedRightMessage
    case .secureNote:
      return CoreLocalization.L10n.Core.kwSecureNoteLimitedRightMessage
    default:
      return ""
    }
  }

  public func isAssociated(to: PremiumStatusTeamInfo) -> Bool {
    return false
  }
}

extension VaultItem {
  public func reportableInfo() -> ActivityLogReportableInfo? {
    return nil
  }
}

public enum VaultItemEnumeration {
  case credential(Credential)
  case secureNote(SecureNote)
  case secret(Secret)
  case bankAccount(BankAccount)
  case creditCard(CreditCard)
  case identity(Identity)
  case email(Email)
  case phone(Phone)
  case address(Address)
  case company(Company)
  case personalWebsite(PersonalWebsite)
  case passport(Passport)
  case idCard(IDCard)
  case fiscalInformation(FiscalInformation)
  case socialSecurityInformation(SocialSecurityInformation)
  case drivingLicence(DrivingLicence)
  case passkey(Passkey)
}

public enum VaultItemIcon: Equatable {
  case address
  case bankAccount
  case company
  case creditCard(CreditCard)
  case credential(Credential)
  case drivingLicense
  case email
  case idCard
  case identity
  case passkey(Passkey)
  case passport
  case personalWebsite
  case phoneNumber
  case secret
  case secureNote(Color)
  case socialSecurityCard
  case `static`(_ asset: SwiftUI.Image, backgroundColor: SwiftUI.Color? = nil)
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
