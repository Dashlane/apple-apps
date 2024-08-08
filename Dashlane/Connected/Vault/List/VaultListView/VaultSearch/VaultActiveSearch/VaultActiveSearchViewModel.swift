import Combine
import CoreLocalization
import CoreSharing
import CoreUserTracking
import Foundation
import UIKit
import VaultKit

class VaultActiveSearchViewModel: ObservableObject, SessionServicesInjecting {
  @Published var searchResult: SearchResult
  @Published var recentSearchSections: [DataSection] = []

  @Published var isSearchActive: Bool = false {
    didSet {
      if isSearchActive {
        activityReporter.reportPageShown(.search)
      }
    }
  }

  let activeFilter: ItemCategory?
  private let searchCriteriaPublisher: AnyPublisher<String, Never>
  private let queue = DispatchQueue(label: "globalSearch", qos: .userInitiated)
  private let activityReporter: ActivityReporterProtocol
  private let completion: (VaultListCompletion) -> Void
  private let vaultItemDatabase: VaultItemDatabaseProtocol
  private let vaultItemsStore: VaultItemsStore
  private let vaultCollectionsStore: VaultCollectionsStore
  private let sharingService: SharedVaultHandling
  private let searchCategory: ItemCategory?
  private var cancellables: Set<AnyCancellable> = .init()
  private let rowModelFactory: ActionableVaultItemRowViewModel.Factory

  init(
    searchCriteriaPublisher: AnyPublisher<String, Never>,
    searchResult: SearchResult = SearchResult(searchCriteria: "", sections: []),
    searchCategory: ItemCategory?,
    activityReporter: ActivityReporterProtocol,
    vaultItemDatabase: VaultItemDatabaseProtocol,
    vaultItemsStore: VaultItemsStore,
    vaultCollectionsStore: VaultCollectionsStore,
    sharingService: SharedVaultHandling,
    rowModelFactory: ActionableVaultItemRowViewModel.Factory,
    completion: @escaping (VaultListCompletion) -> Void
  ) {
    self.activityReporter = activityReporter
    self.vaultItemDatabase = vaultItemDatabase
    self.vaultItemsStore = vaultItemsStore
    self.sharingService = sharingService
    self.searchResult = searchResult
    self.completion = completion
    self.rowModelFactory = rowModelFactory
    self.searchCategory = searchCategory
    self.vaultCollectionsStore = vaultCollectionsStore
    self.activeFilter = searchCategory
    self.searchCriteriaPublisher = searchCriteriaPublisher
    setup()
  }

  func setup() {
    let itemsPublisher =
      vaultItemsStore
      .itemsPublisher(for: searchCategory)
      .receive(on: queue)

    let collectionsPublisher = vaultCollectionsStore
      .$collections
      .receive(on: queue)

    setupSearchPublisher(
      itemsPublisher: itemsPublisher.eraseToAnyPublisher(),
      collectionsPublisher: collectionsPublisher.eraseToAnyPublisher()
    )

    itemsPublisher
      .map { items -> [DataSection] in
        let recentSearchedItems =
          items
          .filter { $0.metadata.lastLocalSearchDate != nil }
          .sorted { left, right in
            guard let leftDate = left.metadata.lastLocalSearchDate,
              let rightDate = right.metadata.lastLocalSearchDate
            else { return false }
            return leftDate > rightDate
          }
        return [DataSection(name: L10n.Localizable.recentSearchTitle, items: recentSearchedItems)]
      }
      .receive(on: DispatchQueue.main)
      .assign(to: \.recentSearchSections, on: self)
      .store(in: &cancellables)
  }

  public func setupSearchPublisher(
    itemsPublisher: AnyPublisher<[VaultItem], Never>,
    collectionsPublisher: AnyPublisher<[VaultCollection], Never>
  ) {
    let searchPublisher =
      searchCriteriaPublisher
      .removeDuplicates()
      .debounce(for: .milliseconds(200), scheduler: queue)

    let searchItemsPublisher = itemsPublisher.combineLatest(searchPublisher) {
      (items, criteria) -> DataSection? in
      guard !criteria.isEmpty else { return nil }
      let filteredItems = items.filterAndSortItemsUsingCriteria(criteria)

      guard !filteredItems.isEmpty else { return nil }
      let sectionTitle =
        filteredItems.count > 1
        ? CoreLocalization.L10n.Core.KWVault.Search.Items.Title.plural
        : CoreLocalization.L10n.Core.KWVault.Search.Items.Title.singular

      return DataSection(name: sectionTitle, items: filteredItems)
    }

    let searchCollectionsPublisher =
      collectionsPublisher
      .combineLatest(itemsPublisher, searchPublisher) {
        (collections, items, criteria) -> [DataSection] in
        guard !criteria.isEmpty else { return [] }

        return
          collections
          .filterAndSortItemsUsingCriteria(criteria)
          .compactMap { collection -> DataSection? in
            let filteredItems = items.compactMap { item in collection.contains(item) ? item : nil }
            guard !filteredItems.isEmpty else { return nil }
            return DataSection(
              name: CoreLocalization.L10n.Core.KWVault.Search.Collections.title,
              type: .collection(name: collection.name, isShared: collection.isShared),
              items: filteredItems
            )
          }
      }

    searchCollectionsPublisher
      .combineLatest(searchItemsPublisher, searchPublisher) {
        collectionsSections, itemsSections, criteria in
        let sections: [DataSection] = collectionsSections + [itemsSections].compactMap { $0 }
        return SearchResult(searchCriteria: criteria, sections: sections)
      }
      .receive(on: DispatchQueue.main)
      .assign(to: &$searchResult)

    $searchResult
      .debounce(for: .seconds(1), scheduler: DispatchQueue.global())
      .filter { !$0.searchCriteria.isEmpty }
      .map {
        $0.sections
          .map(\.items)
          .flatMap { $0 }
          .map(\.displayTitle)
          .joined(separator: ", ")
      }
      .receive(on: DispatchQueue.main)
      .sink { itemsList in
        let announcement =
          itemsList.isEmpty ? L10n.Localizable.searchVaultNoResultFoundTitle : itemsList
        UIAccessibility.fiberPost(.announcement, argument: announcement)
      }
      .store(in: &cancellables)
  }

  func makeRowViewModel(
    _ item: VaultItem,
    isSuggestedItem: Bool,
    isInCollection: Bool = false,
    origin: ActionableVaultItemRowViewModel.Origin
  ) -> ActionableVaultItemRowViewModel {
    rowModelFactory.make(
      item: item,
      isSuggested: isSuggestedItem,
      origin: origin
    )
  }

  func add(type: VaultItem.Type) {
    completion(.addItem(.itemType(type)))
  }

  func select(_ selection: VaultSelection, isEditing: Bool = false) {
    completion(
      .enterDetail(
        selection.item,
        selectVaultItem(selection),
        isEditing: isEditing)
    )
  }

  private func selectVaultItem(_ selection: VaultSelection) -> UserEvent.SelectVaultItem {
    UserEvent.SelectVaultItem(
      highlight: selection.origin.definitionHighlight,
      itemId: selection.item.userTrackingLogID,
      itemType: selection.item.vaultItemType,
      totalCount: selection.count
    )
  }

  func itemDeleteBehaviour(for item: VaultItem) async throws -> ItemDeleteBehaviour {
    try await sharingService.deleteBehaviour(for: item)
  }

  func delete(item: VaultItem) {
    vaultItemDatabase.dispatchDelete(item)
  }

  func onAddItemDropdown() {
    activityReporter.reportPageShown(.homeAddItemDropdown)
  }
}

extension VaultActiveSearchViewModel {
  static var mock: VaultActiveSearchViewModel {
    .init(
      searchCriteriaPublisher: Just("search").eraseToAnyPublisher(),
      searchCategory: nil,
      activityReporter: .mock,
      vaultItemDatabase: MockVaultKitServicesContainer().vaultItemDatabase,
      vaultItemsStore: MockVaultKitServicesContainer().vaultItemsStore,
      vaultCollectionsStore: MockVaultKitServicesContainer().vaultCollectionsStore,
      sharingService: SharedVaultHandlerMock(),
      rowModelFactory: .init { item, _, _ in .mock(item: item) },
      completion: { _ in }
    )
  }
}
