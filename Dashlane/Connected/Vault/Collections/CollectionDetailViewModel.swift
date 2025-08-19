import Combine
import CoreFeature
import CoreLocalization
import CorePersonalData
import CorePremium
import CoreTypes
import DesignSystem
import Foundation
import LogFoundation
import UserTrackingFoundation
import VaultKit

@MainActor
final class CollectionDetailViewModel: ObservableObject, SessionServicesInjecting {

  struct Section {
    enum `Type` {
      case credentials
      case secureNotes
      case secrets
      case others
    }

    let type: `Type`
    let items: [VaultItem]
  }

  @Published var collection: VaultCollection {
    didSet {
      updateSections()
    }
  }

  @Published var sections: [CollectionDetailViewModel.Section] = []

  var collectionSpace: UserSpace? {
    userSpacesService.configuration.displayedUserSpace(for: collection)
  }

  var shouldShowSpace: Bool {
    userSpacesService.configuration.availableSpaces.count > 1
  }

  @Published
  var starterInfo: StarterInfo = .none

  private let collectionQuickActionsMenuViewModelFactory:
    CollectionQuickActionsMenuViewModel.Factory
  private let rowModelFactory: ActionableVaultItemRowViewModel.Factory

  private let logger: Logger
  private let featureService: FeatureServiceProtocol
  private let activityReporter: ActivityReporterProtocol
  private let vaultItemsStore: VaultItemsStore
  private let vaultCollectionsStore: VaultCollectionsStore
  private let vaultCollectionEditionService: VaultCollectionEditionService
  private let userSpacesService: UserSpacesService
  private let premiumStatusProvider: PremiumStatusProvider

  private var cancellables: Set<AnyCancellable> = []

  init(
    collection: VaultCollection,
    logger: Logger,
    featureService: FeatureServiceProtocol,
    activityReporter: ActivityReporterProtocol,
    vaultItemsStore: VaultItemsStore,
    vaultCollectionsStore: VaultCollectionsStore,
    userSpacesService: UserSpacesService,
    premiumStatusProvider: PremiumStatusProvider,
    collectionQuickActionsMenuViewModelFactory: CollectionQuickActionsMenuViewModel.Factory,
    rowModelFactory: ActionableVaultItemRowViewModel.Factory,
    vaultCollectionEditionServiceFactory: VaultCollectionEditionService.Factory
  ) {
    self.collection = collection
    self.logger = logger
    self.featureService = featureService
    self.activityReporter = activityReporter
    self.vaultItemsStore = vaultItemsStore
    self.vaultCollectionsStore = vaultCollectionsStore
    self.collectionQuickActionsMenuViewModelFactory = collectionQuickActionsMenuViewModelFactory
    self.rowModelFactory = rowModelFactory
    self.userSpacesService = userSpacesService
    self.premiumStatusProvider = premiumStatusProvider
    self.vaultCollectionEditionService = vaultCollectionEditionServiceFactory.make(
      collection: collection)
    self.sections = makeSections(with: vaultItemsStore.allItems())

    registerPublishers()
  }

  private func registerPublishers() {
    vaultCollectionsStore
      .$collections
      .receive(on: DispatchQueue.main)
      .sink { [weak self] collections in
        if let collection = collections.first(where: { $0.id == self?.collection.id }) {
          self?.collection = collection
        }
      }
      .store(in: &cancellables)

    vaultItemsStore
      .allItemsPublisher()
      .map { [weak self] items -> [CollectionDetailViewModel.Section] in
        self?.makeSections(with: items) ?? []
      }
      .receive(on: DispatchQueue.main)
      .assign(to: &$sections)

    registerStarterPublisher()
  }

  private func updateSections() {
    DispatchQueue.main.async {
      self.sections = self.makeSections(with: self.vaultItemsStore.allItems())
    }
  }

  private func makeSections(with items: [VaultItem]) -> [CollectionDetailViewModel.Section] {
    var sections: [CollectionDetailViewModel.Section] = []

    let items = items.filter { collection.contains($0) }
    var credentials: [VaultItem] = []
    var secureNotes: [VaultItem] = []
    var secrets: [VaultItem] = []
    var others: [VaultItem] = []

    for item in items {
      switch item.enumerated {
      case .credential:
        credentials.append(item)
      case .secureNote:
        secureNotes.append(item)
      case .secret:
        secrets.append(item)
      default:
        others.append(item)
      }
    }

    if !credentials.isEmpty {
      sections.append(.init(type: .credentials, items: credentials))
    }
    if !secureNotes.isEmpty {
      sections.append(.init(type: .secureNotes, items: secureNotes))
    }
    if !secrets.isEmpty {
      sections.append(.init(type: .secrets, items: secrets))
    }
    if !others.isEmpty {
      sections.append(.init(type: .others, items: others))
    }

    return sections
  }
}

extension CollectionDetailViewModel {
  func makeQuickActionsMenuViewModel() -> CollectionQuickActionsMenuViewModel {
    collectionQuickActionsMenuViewModelFactory.make(collection: collection)
  }

  func makeRowViewModel(_ item: VaultItem) -> ActionableVaultItemRowViewModel {
    rowModelFactory.make(
      item: item,
      isSuggested: false,
      origin: .vault)
  }
}

extension VaultItemsStore {
  fileprivate func allItems() -> [VaultItem] {
    var allItems: [VaultItem] = []
    allItems.append(contentsOf: credentials)
    allItems.append(contentsOf: secureNotes)
    allItems.append(contentsOf: creditCards)
    allItems.append(contentsOf: bankAccounts)
    allItems.append(contentsOf: identities)
    allItems.append(contentsOf: emails)
    allItems.append(contentsOf: phones)
    allItems.append(contentsOf: addresses)
    allItems.append(contentsOf: companies)
    allItems.append(contentsOf: websites)
    allItems.append(contentsOf: passports)
    allItems.append(contentsOf: drivingLicenses)
    allItems.append(contentsOf: socialSecurityInformation)
    allItems.append(contentsOf: idCards)
    allItems.append(contentsOf: fiscalInformation)

    return allItems
  }
}

extension CollectionDetailViewModel {
  enum StarterInfo {
    case none
    case warning
    case limitReached
    case limitReachedAndEditing
    case businessTrialWarning
  }

  private func registerStarterPublisher() {
    vaultCollectionsStore
      .$collections
      .combineLatest(premiumStatusProvider.statusPublisher) { [weak self] (collections, status) in
        guard let self = self, let team = status.b2bStatus?.currentTeam else { return .none }
        guard team.isAdminOfABusinessTeamInTrial == false else {
          return .businessTrialWarning
        }
        guard
          team.isAdminOfAStarterTeam == true
            && status.isConcernedByStarterPlanSharingLimit
        else {
          return .none
        }
        let sharedCollectionsCount = collections.filter { $0.isShared }.count
        if status.hasSharingDisabledBecauseOfStarterPlanLimitation(
          alreadySharedCollectionsCount: sharedCollectionsCount)
        {
          return collection.isShared ? .limitReachedAndEditing : .limitReached
        } else {
          return .warning
        }
      }
      .receive(on: DispatchQueue.main)
      .assign(to: &$starterInfo)
  }

  var isSharingLimitedByStartedPlan: Bool {
    guard let team = premiumStatusProvider.status.b2bStatus?.currentTeam else {
      return false
    }
    return !team.isAdminOfAStarterTeam
      && premiumStatusProvider.status.isConcernedByStarterPlanSharingLimit
  }
}

extension CollectionDetailViewModel {
  func remove(_ item: VaultItem, with toast: ToastAction) {
    Task {
      _ = try? await vaultCollectionEditionService.remove(item)
      toast(
        CoreL10n.KWVaultItem.Collections.Toast.itemRemoved(1),
        image: .ds.feedback.success.outlined
      )
    }
  }
}

extension CollectionDetailViewModel {
  static func mock(for collection: VaultCollection) -> CollectionDetailViewModel {
    .init(
      collection: collection,
      logger: .mock,
      featureService: .mock(),
      activityReporter: .mock,
      vaultItemsStore: MockVaultKitServicesContainer().vaultItemsStore,
      vaultCollectionsStore: MockVaultKitServicesContainer().vaultCollectionsStore,
      userSpacesService: .mock(),
      premiumStatusProvider: .mock(),
      collectionQuickActionsMenuViewModelFactory: .init { collection in
        .mock(collection: collection)
      },
      rowModelFactory: .init { item, _, _ in .mock(item: item) },
      vaultCollectionEditionServiceFactory: .init { .mock($0) }
    )
  }
}
