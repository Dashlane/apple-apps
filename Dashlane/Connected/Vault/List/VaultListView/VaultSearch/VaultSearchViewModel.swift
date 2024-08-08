import Combine
import CoreFeature
import CoreLocalization
import CoreUserTracking
import Foundation
import VaultKit

@MainActor
class VaultSearchViewModel: ObservableObject, SessionServicesInjecting {
  @Published public var searchCriteria: String

  @Published var isSearchActive: Bool = false {
    didSet {
      if isSearchActive {
        activityReporter.reportPageShown(.search)
      }
    }
  }

  let userSwitcherViewModelFactory: UserSpaceSwitcherViewModel.Factory
  let deeplinkPublisher: AnyPublisher<DeepLink, Never>
  private let queue = DispatchQueue(label: "globalSearch", qos: .userInitiated)
  private let activityReporter: ActivityReporterProtocol
  private let completion: (VaultListCompletion) -> Void
  private let activeSearchFactory: VaultActiveSearchViewModel.Factory
  private let searchCategory: ItemCategory?

  init(
    searchCriteria: String = "",
    searchCategory: ItemCategory?,
    activityReporter: ActivityReporterProtocol,
    deeplinkingService: DeepLinkingServiceProtocol,
    activeSearchFactory: VaultActiveSearchViewModel.Factory,
    userSwitcherViewModelFactory: UserSpaceSwitcherViewModel.Factory,
    completion: @escaping (VaultListCompletion) -> Void
  ) {
    self.activityReporter = activityReporter
    self.searchCriteria = searchCriteria
    self.completion = completion
    self.activeSearchFactory = activeSearchFactory
    self.searchCategory = searchCategory
    self.deeplinkPublisher = deeplinkingService.deepLinkPublisher
    self.userSwitcherViewModelFactory = userSwitcherViewModelFactory
  }

  func add(type: VaultItem.Type) {
    completion(.addItem(.itemType(type)))
  }

  func makeActiveSearchViewModel() -> VaultActiveSearchViewModel {
    activeSearchFactory.make(
      searchCriteriaPublisher: $searchCriteria.eraseToAnyPublisher(),
      searchCategory: searchCategory,
      completion: completion
    )
  }

  func displaySearch(for query: String) {
    searchCriteria = query
    isSearchActive = true
  }
}

extension VaultSearchViewModel {
  func onAddItemDropdown() {
    activityReporter.reportPageShown(.homeAddItemDropdown)
  }
}

extension VaultSearchViewModel {
  static var mock: VaultSearchViewModel {
    .init(
      searchCategory: nil,
      activityReporter: .mock,
      deeplinkingService: DeepLinkingService.fakeService,
      activeSearchFactory: .init { _, _, _, _ in .mock },
      userSwitcherViewModelFactory: .init { .mock },
      completion: { _ in }
    )
  }
}
