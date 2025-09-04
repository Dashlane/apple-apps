import Combine
import CorePersonalData
import CorePremium
import CoreTypes
import Foundation
import VaultKit

@MainActor
class ShareItemsSelectionViewModel: ObservableObject, SessionServicesInjecting,
  MockVaultConnectedInjecting
{
  @Published
  var search: String = ""

  @Published
  var sections: [DataSection] = []

  @Published
  var selectedItems: [Identifier: VaultItem] = [:]

  let vaultItemIconViewModelFactory: VaultItemIconViewModel.Factory
  let userSpacesService: UserSpacesService
  let completion: @MainActor ([VaultItem]) -> Void

  convenience init(
    vaultItemsStore: VaultItemsStore,
    userSpacesService: UserSpacesService,
    vaultItemIconViewModelFactory: VaultItemIconViewModel.Factory,
    completion: @escaping @MainActor ([VaultItem]) -> Void
  ) {
    var publishers: [AnyPublisher<[VaultItem], Never>] = []
    for type in SharingType.allCases {
      switch type {
      case .password:
        publishers.append(
          vaultItemsStore.$credentials.map { $0 as [VaultItem] }.eraseToAnyPublisher())
      case .note:
        publishers.append(
          vaultItemsStore.$secureNotes.map { $0 as [VaultItem] }.eraseToAnyPublisher())
      case .secret:
        publishers.append(vaultItemsStore.$secrets.map { $0 as [VaultItem] }.eraseToAnyPublisher())
      }
    }
    let publisher = publishers.combineLatest().map { items in
      items.flatMap { $0 }
    }

    self.init(
      vaultItemsPublisher: publisher,
      userSpacesService: userSpacesService,
      vaultItemIconViewModelFactory: vaultItemIconViewModelFactory,
      completion: completion)
  }

  private init<P: Publisher>(
    vaultItemsPublisher: P,
    userSpacesService: UserSpacesService,
    vaultItemIconViewModelFactory: VaultItemIconViewModel.Factory,
    completion: @escaping @MainActor ([VaultItem]) -> Void
  ) where P.Output == [VaultItem], P.Failure == Never {
    self.vaultItemIconViewModelFactory = vaultItemIconViewModelFactory
    self.userSpacesService = userSpacesService
    self.completion = completion

    let itemsPublisher =
      vaultItemsPublisher
      .receive(on: DispatchQueue.global(qos: .userInitiated))
      .map { items in
        return items.filter { !$0.hasAttachments && $0.metadata.sharingPermission != .limited }
      }
      .filter(by: userSpacesService.$configuration)

    let searchPublisher =
      $search
      .dropFirst()
      .debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
      .prepend("")
      .receive(on: DispatchQueue.global(qos: .userInitiated))

    itemsPublisher.combineLatest(searchPublisher) { items, search in
      let items = search.isEmpty ? items : items.filterAndSortItemsUsingCriteria(search)

      return items.alphabeticallyGrouped()
    }
    .receive(on: DispatchQueue.main)
    .assign(to: &$sections)
  }

  func toggle(_ item: VaultItem) {
    if isSelected(item) {
      selectedItems.removeValue(forKey: item.id)
    } else {
      selectedItems[item.id] = item
    }
  }

  func isSelected(_ item: VaultItem) -> Bool {
    return selectedItems[item.id] != nil
  }

  func complete() {
    completion(Array(selectedItems.values))
  }
}

extension ShareItemsSelectionViewModel {

  static func mock(
    vaultItems: [VaultItem] = PersonalDataMock.shareableItems,
    completion: @escaping @MainActor ([VaultItem]) -> Void = { _ in }
  ) -> ShareItemsSelectionViewModel {
    ShareItemsSelectionViewModel(
      vaultItemsPublisher: Just(vaultItems),
      userSpacesService: .mock(),
      vaultItemIconViewModelFactory: .init { item in .mock(item: item) },
      completion: completion
    )
  }
}

extension PersonalDataMock {
  static let shareableItems: [VaultItem] = [
    PersonalDataMock.Credentials.adobe,
    PersonalDataMock.Credentials.amazon,
    PersonalDataMock.SecureNotes.thinkDifferent,
  ]
}
