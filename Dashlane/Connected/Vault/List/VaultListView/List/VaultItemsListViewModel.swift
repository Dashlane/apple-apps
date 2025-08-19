import AutofillKit
import Combine
import CoreFeature
import CorePersonalData
import CorePremium
import CoreSettings
import CoreSharing
import Foundation
import ImportKit
import NotificationKit
import UserTrackingFoundation
import VaultKit

class VaultItemsListViewModel: ObservableObject, SessionServicesInjecting {
  @Published var sections: [DataSection] = []

  @Published
  var activeFilter: ItemCategory?

  @Published
  var isLoading: Bool = true

  var isSecureNoteDisabled: Bool {
    featureService.isEnabled(.disableSecureNotes)
  }

  private let completion: (VaultListCompletion) -> Void
  private let queue = DispatchQueue(label: "com.dashlane.activeFilter", qos: .userInitiated)
  private let rowModelFactory: ActionableVaultItemRowViewModel.Factory
  private let vaultItemsStore: VaultItemsStore
  private let vaultItemDatabase: VaultItemDatabaseProtocol
  private let capabilityService: CapabilityServiceProtocol
  private let activityReporter: ActivityReporterProtocol
  private let featureService: FeatureServiceProtocol
  private let sharingService: SharedVaultHandling
  private let userSettings: UserSettings
  private let activeFilterPublisher: AnyPublisher<ItemCategory?, Never>
  private var subscriptions: Set<AnyCancellable> = []

  init(
    vaultItemsStore: VaultItemsStore,
    vaultItemDatabase: VaultItemDatabaseProtocol,
    userSettings: UserSettings,
    capabilityService: CapabilityServiceProtocol,
    sharingService: SharedVaultHandling,
    featureService: FeatureServiceProtocol,
    activityReporter: ActivityReporterProtocol,
    rowModelFactory: ActionableVaultItemRowViewModel.Factory,
    activeFilter: ItemCategory?,
    activeFilterPublisher: AnyPublisher<ItemCategory?, Never>,
    completion: @escaping (VaultListCompletion) -> Void
  ) {
    self.featureService = featureService
    self.activityReporter = activityReporter
    self.userSettings = userSettings
    self.capabilityService = capabilityService
    self.vaultItemsStore = vaultItemsStore
    self.vaultItemDatabase = vaultItemDatabase
    self.sharingService = sharingService
    self.rowModelFactory = rowModelFactory
    self.completion = completion
    self.activeFilter = activeFilter
    self.activeFilterPublisher = activeFilterPublisher
    activeFilterPublisher.assign(to: &$activeFilter)

    setupSectionPublisher()
  }

  private func setupSectionPublisher() {
    activeFilterPublisher
      .receive(on: queue)
      .map { [vaultItemsStore] activeFilter in
        vaultItemsStore.dataSectionsPublisher(for: activeFilter)
      }
      .switchToLatest()
      .receive(on: queue)
      .map { sections -> [DataSection] in
        return sections.addingSuggestedSection(name: L10n.Localizable.suggested)
      }
      .filterEmpty()
      .receive(on: DispatchQueue.main)
      .sink { [weak self] sections in
        self?.sections = sections
        self?.isLoading = false
      }
      .store(in: &subscriptions)
  }

  func count(for vaultSelectionOrigin: VaultSelectionOrigin) -> Int {
    let isFromSuggested = vaultSelectionOrigin == .suggestedItems
    return sections.filter {
      $0.isSuggestedItems == isFromSuggested
    }
    .flatMap(\.items).count
  }

  func sectionNameForFooter() -> String {
    let count = count(for: .regularList)
    var sectionName =
      count == 1
      ? activeFilter?.sectionSingular(count: count) ?? L10n.Localizable.sectionItem(count)
      : activeFilter?.sectionPlural(count: count) ?? L10n.Localizable.sectionItems(count)
    switch activeFilter {
    case .secureNotes, .ids:
      break
    default:
      sectionName = sectionName.lowercased()
    }

    return sectionName
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
    return try await sharingService.deleteBehaviour(for: item)
  }

  func delete(item: VaultItem) {
    vaultItemDatabase.dispatchDelete(item)
  }

  func add(type: VaultItem.Type) {
    completion(.addItem(.itemType(type)))
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
}

extension VaultItemsListViewModel {
  static var mock: VaultItemsListViewModel {
    .init(
      vaultItemsStore: MockVaultKitServicesContainer().vaultItemsStore,
      vaultItemDatabase: MockVaultKitServicesContainer().vaultItemDatabase,
      userSettings: .mock,
      capabilityService: .mock(),
      sharingService: SharedVaultHandlerMock(),
      featureService: .mock(),
      activityReporter: .mock,
      rowModelFactory: .init { item, _, _ in .mock(item: item) },
      activeFilter: nil,
      activeFilterPublisher: Just(nil).eraseToAnyPublisher(),
      completion: { _ in }
    )
  }
}
