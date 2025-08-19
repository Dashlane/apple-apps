import Combine
import CoreLocalization
import CorePersonalData
import Foundation

open class SearchViewModel {
  @Published
  public var searchCriteria: String

  @Published
  public var searchResult: SearchResult

  public let queue = DispatchQueue(label: "globalSearch", qos: .userInitiated)

  private var areCollectionsEnabled: Bool

  public init(
    searchCriteria: String = "",
    searchResult: SearchResult = SearchResult(searchCriteria: "", sections: []),
    areCollectionsEnabled: Bool
  ) {
    self.searchCriteria = searchCriteria
    self.searchResult = searchResult
    self.areCollectionsEnabled = areCollectionsEnabled
  }

  public func setupSearchPublisher(
    itemsPublisher: AnyPublisher<[VaultItem], Never>,
    collectionsPublisher: AnyPublisher<[VaultCollection], Never>
  ) {
    let searchPublisher =
      $searchCriteria
      .removeDuplicates()
      .debounce(for: .milliseconds(200), scheduler: queue)
      .prepend("")

    let searchItemsPublisher = itemsPublisher.combineLatest(searchPublisher) {
      (items, criteria) -> DataSection? in
      guard !criteria.isEmpty else { return nil }
      let filteredItems = items.filterAndSortItemsUsingCriteria(criteria)

      guard !filteredItems.isEmpty else { return nil }
      let sectionTitle =
        filteredItems.count > 1
        ? CoreL10n.KWVault.Search.Items.Title.plural : CoreL10n.KWVault.Search.Items.Title.singular

      return DataSection(name: sectionTitle, items: filteredItems)
    }

    let searchCollectionsPublisher =
      collectionsPublisher
      .combineLatest(itemsPublisher, searchPublisher) {
        [weak self] (collections, items, criteria) -> [DataSection] in
        guard self?.areCollectionsEnabled == true else { return [] }
        guard !criteria.isEmpty else { return [] }

        return
          collections
          .filterAndSortItemsUsingCriteria(criteria)
          .compactMap { collection in
            let filteredItems = items.compactMap { item in collection.contains(item) ? item : nil }
            guard !filteredItems.isEmpty else { return nil }
            return DataSection(
              name: CoreL10n.KWVault.Search.Collections.title,
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
  }
}
