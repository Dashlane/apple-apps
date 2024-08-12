import Combine
import CoreFeature
import CorePersonalData
import CoreUserTracking
import Foundation
import IconLibrary
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

  let domainIconLibrary: DomainIconLibrary
  private let queue = DispatchQueue(label: "extensionSearch", qos: .userInteractive)
  private var cancellables = Set<AnyCancellable>()
  private let credentialsListService: CredentialListService
  private let sessionActivityReporter: ActivityReporterProtocol
  let vaultItemIconViewModelFactory: VaultItemIconViewModel.Factory

  init(
    credentialsListService: CredentialListService,
    domainIconLibrary: DomainIconLibrary,
    vaultItemIconViewModelFactory: VaultItemIconViewModel.Factory,
    sessionActivityReporter: ActivityReporterProtocol
  ) {
    self.vaultItemIconViewModelFactory = vaultItemIconViewModelFactory
    self.credentialsListService = credentialsListService
    self.searchCriteria = ""
    self.isActive = false
    self.domainIconLibrary = domainIconLibrary
    self.sessionActivityReporter = sessionActivityReporter
    setup()
  }

  func setup() {
    let searchPublisher =
      $searchCriteria
      .debounce(for: .milliseconds(300), scheduler: queue)

    credentialsListService
      .$allCredentials
      .receive(on: queue)
      .combineLatest(searchPublisher) { credentials, criteria in
        guard !criteria.isEmpty else {
          return SearchResult(searchCriteria: criteria, sections: [])
        }

        let filteredCredentials =
          credentials
          .filterAndSortItemsUsingCriteria(criteria)

        let section = DataSection(items: filteredCredentials)
        let result = SearchResult(searchCriteria: criteria, sections: [section])
        return result
      }
      .receive(on: DispatchQueue.main)
      .assign(to: &$result)

    credentialsListService
      .$allCredentials
      .receive(on: queue)
      .map { credentials -> [DataSection] in
        let recentSearchedItems =
          credentials
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
