import CorePersonalData
import CoreTypes
import Foundation
import SwiftTreats
import UserTrackingFoundation
import VaultKit

extension VaultFlowViewModel {
  func createCredential(using password: GeneratedPassword) {
    showAddItemMenuView(displayMode: .prefilledPassword(password))
  }
  var title: String {
    mode.title
  }

  func canHandle(deepLink: VaultDeeplink) -> Bool {
    if mode.isShowingAllItems {
      return true
    }

    switch deepLink {
    case let .list(category):
      return title == category?.title
    case let .fetchAndShow(identifier, _):
      return title == identifier.component.category?.title
    case let .show(item, _, _):
      return title == item.deepLinkIdentifier.component.category?.title
    case let .create(component):
      return title == component.category?.title
    }
  }

  func handle(_ deepLink: VaultDeeplink) {
    steps.removeLast(steps.count - 1)
    switch deepLink {
    case let .list(category):
      showList(for: category)
    case let .fetchAndShow(identifier, useEditMode):
      guard let item = vaultItemDatabase.item(for: identifier) else { return }
      showDetail(for: item, selectVaultItem: selectVaultItem(item), isEditing: useEditMode)
    case let .show(item, useEditMode: useEditMode, origin: origin):
      showDetail(
        for: item,
        selectVaultItem: selectVaultItem(item),
        isEditing: useEditMode,
        origin: origin
      )
    case let .create(component):
      guard showAddItemFlow == false else {
        return
      }
      if component.isCategory {
        if let category = component.category {
          showAddItemMenuView(displayMode: .categoryDetail(category))
        }
      } else {
        showAddItemMenuView(displayMode: .itemType(component.type))
      }
    }
  }

  func selectVaultItem(_ item: VaultItem) -> UserEvent.SelectVaultItem {
    UserEvent.SelectVaultItem(
      highlight: .none,
      itemId: item.userTrackingLogID,
      itemType: item.vaultItemType
    )
  }

  private func showList(for category: ItemCategory?) {
    DispatchQueue.main.async {
      self.steps.removeLast(self.steps.count - 1)

      if case .allItems = self.mode {
        self.activeFilter = category
      }
    }
  }

  private func editMode(item: VaultItem, editMode: Bool, origin: ItemDetailOrigin)
    -> ItemDetailViewType
  {
    return editMode
      ? .editing(item) : .viewing(item, actionPublisher: actionPublisher, origin: origin)
  }
}

extension VaultItemDatabaseProtocol {

  fileprivate func item(for identifier: VaultDeepLinkIdentifier) -> VaultItem? {
    var rawIdentifier = identifier.rawIdentifier
    if rawIdentifier.first != "{" && rawIdentifier.last != "}" {
      rawIdentifier = "{\(rawIdentifier)}"
    }
    switch identifier.component {
    case .credential:
      return try? fetch(with: Identifier(rawIdentifier), type: Credential.self)
    case .secureNote:
      return try? fetch(with: Identifier(rawIdentifier), type: SecureNote.self)
    case .bankAccount:
      return try? fetch(with: Identifier(rawIdentifier), type: BankAccount.self)
    case .creditCard:
      return try? fetch(with: Identifier(rawIdentifier), type: CreditCard.self)
    case .identity:
      return try? fetch(with: Identifier(rawIdentifier), type: Identity.self)
    case .email:
      return try? fetch(with: Identifier(rawIdentifier), type: Email.self)
    case .phone:
      return try? fetch(with: Identifier(rawIdentifier), type: Phone.self)
    case .address:
      return try? fetch(with: Identifier(rawIdentifier), type: Address.self)
    case .company:
      return try? fetch(with: Identifier(rawIdentifier), type: Company.self)
    case .personalWebsite:
      return try? fetch(with: Identifier(rawIdentifier), type: PersonalWebsite.self)
    case .identityCards:
      return try? fetch(with: Identifier(rawIdentifier), type: IDCard.self)
    case .passports:
      return try? fetch(with: Identifier(rawIdentifier), type: Passport.self)
    case .driverLicense:
      return try? fetch(with: Identifier(rawIdentifier), type: DrivingLicence.self)
    case .socialSecurityNumber:
      return try? fetch(with: Identifier(rawIdentifier), type: SocialSecurityInformation.self)
    case .fiscal:
      return try? fetch(with: Identifier(rawIdentifier), type: FiscalInformation.self)
    default:
      return nil
    }
  }
}

extension VaultFlowViewModel.Mode {
  fileprivate var title: String {
    switch self {
    case .allItems:
      return L10n.Localizable.recentTitle
    case .category(let category):
      return category.title
    }
  }
}
