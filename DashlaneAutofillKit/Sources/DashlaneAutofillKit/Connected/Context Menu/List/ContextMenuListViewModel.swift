import AutofillKit
import Combine
import CoreFeature
import CoreLocalization
import CorePersonalData
import CorePremium
import CoreTeamAuditLogs
import CoreTypes
import Foundation
import LogFoundation
import UserTrackingFoundation
import VaultKit

@MainActor
class ContextMenuListViewModel: ObservableObject, SessionServicesInjecting {

  enum State: Hashable {
    case loading
    case ready
  }

  enum Completion {
    case enterDetail(VaultItem, Definition.Highlight)
    case cancel
  }

  @Published var sections: [DataSection] = []
  @Published var activeFilter: ItemCategory?
  @Published var state: State = .loading

  @Published public var searchCriteria: String
  @Published var isSearchActive: Bool = false

  let vaultItemsStore: VaultItemsStore
  let userSpacesService: UserSpacesService
  let vaultItemIconViewModelFactory: VaultItemIconViewModel.Factory
  let completion: (ContextMenuListViewModel.Completion) -> Void

  private let queue = DispatchQueue(
    label: "com.dashlane.activeFilterContextMenuAutofill", qos: .userInitiated)
  private var cancellables: Set<AnyCancellable> = []

  init(
    searchCriteria: String = "",
    activeFilter: ItemCategory?,
    logger: Logger,
    database: ApplicationDatabase,
    featureService: FeatureServiceProtocol,
    userSpacesService: UserSpacesService,
    teamAuditLogsService: TeamAuditLogsServiceProtocol,
    capabilityService: CapabilityService,
    vaultItemDatabase: VaultItemDatabaseProtocol,
    vaultItemIconViewModelFactory: VaultItemIconViewModel.Factory,
    completion: @escaping (ContextMenuListViewModel.Completion) -> Void
  ) {
    self.searchCriteria = searchCriteria
    self.activeFilter = activeFilter
    self.vaultItemIconViewModelFactory = vaultItemIconViewModelFactory
    self.completion = completion
    self.userSpacesService = userSpacesService
    self.vaultItemsStore = VaultItemsStoreImpl(
      userSpacesService: userSpacesService,
      featureService: featureService,
      capabilityService: capabilityService,
      vaultItemDatabase: vaultItemDatabase)
    setupSectionPublisher()
    self.vaultItemsStore.$loaded.sink { [weak self] loaded in
      guard let self else { return }
      if loaded {
        self.state = .ready
      }
    }.store(in: &cancellables)
  }

  func select(_ item: VaultItem, highlight: Definition.Highlight) {
    completion(.enterDetail(item, highlight))
  }

  func highlightForTrackingEvents(isSuggested: Bool) -> Definition.Highlight {
    if isSuggested {
      return .suggested
    } else if isSearchActive {
      return .searchResult
    } else {
      return .none
    }
  }

  private func setupSectionPublisher() {
    let searchPublisher = $searchCriteria.eraseToAnyPublisher()
      .removeDuplicates()
      .debounce(for: .milliseconds(200), scheduler: queue)

    let searchActivePublisher = $isSearchActive.eraseToAnyPublisher()
      .removeDuplicates()

    let activeFilterPublisher = $activeFilter.eraseToAnyPublisher()
      .removeDuplicates()

    activeFilterPublisher
      .combineLatest(searchActivePublisher)
      .receive(on: queue)
      .map { [vaultItemsStore] (activeFilter, searchIsActive) in
        vaultItemsStore.contextMenuAutofillDataSectionsPublisher(
          for: searchIsActive ? nil : activeFilter)
      }
      .switchToLatest()
      .receive(on: queue)
      .combineLatest(searchPublisher) { (sections, criteria) -> [DataSection] in
        guard !criteria.isEmpty else { return sections }
        return sections.map { section in
          let items = section.items
          let filteredItems = items.filterAndSortItemsUsingCriteria(criteria)
          return DataSection(name: section.name, items: filteredItems)
        }
      }
      .map { sections -> [DataSection] in
        return sections.addingSuggestedSection(name: L10n.Localizable.suggested)
      }
      .filterEmpty()
      .receive(on: DispatchQueue.main)
      .assign(to: &$sections)
  }

  func cancel() {
    completion(.cancel)
  }

  func deeplinkURL<T: VaultItem>(for itemType: T.Type) -> URL {
    if let url = VaultDeeplink.createURL(for: itemType) {
      return url
    } else {
      return URL(string: "dashlane:///")!
    }
  }
}

extension ContextMenuListViewModel {
  static var mock: ContextMenuListViewModel {
    .init(
      activeFilter: nil,
      logger: .mock,
      database: .mock(),
      featureService: .mock(),
      userSpacesService: .mock(),
      teamAuditLogsService: .mock(),
      capabilityService: .mock(),
      vaultItemDatabase: .mock(),
      vaultItemIconViewModelFactory: .init { item in .mock(item: item) },
      completion: { _ in })
  }
}
