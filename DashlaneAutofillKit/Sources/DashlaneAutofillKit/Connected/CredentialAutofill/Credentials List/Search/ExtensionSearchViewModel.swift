import Combine
import CoreFeature
import CorePersonalData
import Foundation
import IconLibrary
import UserTrackingFoundation
import VaultKit

@MainActor
class ExtensionSearchViewModel: ObservableObject, SessionServicesInjecting {
  @Published
  var result: SearchResult = SearchResult(searchCriteria: "", sections: [])

  @Published
  var searchCriteria: String

  @Published
  var isActive: Bool {
    didSet {
      if isActive {
        sessionActivityReporter.reportPageShown(.autofillExplorePasswordsSearch)
      }
    }
  }

  @Published
  var recentSearchItems: [DataSection] = []

  let vaultItemIconViewModelFactory: VaultItemIconViewModel.Factory

  private let queue = DispatchQueue(label: "extensionSearch", qos: .userInteractive)
  private var cancellables = Set<AnyCancellable>()
  private let credentialListItemsProvider: CredentialListItemsProvider
  private let sessionActivityReporter: ActivityReporterProtocol

  init(
    credentialListItemsProvider: CredentialListItemsProvider,
    vaultItemIconViewModelFactory: VaultItemIconViewModel.Factory,
    sessionActivityReporter: ActivityReporterProtocol
  ) {
    self.vaultItemIconViewModelFactory = vaultItemIconViewModelFactory
    self.credentialListItemsProvider = credentialListItemsProvider
    self.searchCriteria = ""
    self.isActive = false
    self.sessionActivityReporter = sessionActivityReporter
    setup()
  }

  func setup() {
    let searchPublisher =
      $searchCriteria
      .debounce(for: .milliseconds(300), scheduler: queue)

    credentialListItemsProvider
      .$items
      .compactMap { $0 }
      .receive(on: queue)
      .combineLatest(searchPublisher) { credentials, criteria in
        guard !criteria.isEmpty else {
          return SearchResult(searchCriteria: criteria, sections: [])
        }

        let filteredCredentials = credentials.all
          .filterAndSortItemsUsingCriteria(criteria)

        let section = DataSection(name: "", items: filteredCredentials)
        let result = SearchResult(searchCriteria: criteria, sections: [section])
        return result
      }
      .receive(on: DispatchQueue.main)
      .assign(to: &$result)

    credentialListItemsProvider
      .$items
      .compactMap { $0 }
      .receive(on: queue)
      .map { credentials -> [DataSection] in
        let recentSearchedItems = credentials.all
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
      .assign(to: &$recentSearchItems)
  }
}

extension ExtensionSearchViewModel {
  static var mock: ExtensionSearchViewModel {
    ExtensionSearchViewModel(
      credentialListItemsProvider: .mock,
      vaultItemIconViewModelFactory: .init { item in .mock(item: item) },
      sessionActivityReporter: .mock)
  }
}
