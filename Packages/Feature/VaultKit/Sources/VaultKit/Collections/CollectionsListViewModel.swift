import Combine
import CoreLocalization
import CorePremium
import CoreTypes
import CoreUserTracking
import DesignSystem
import Foundation
import UserTrackingFoundation

@MainActor
public final class CollectionsListViewModel: ObservableObject, VaultKitServicesInjecting {
  enum ViewSate {
    case loading
    case emptyCredentialsList
    case emptyCollectionsList
    case loaded
  }

  @Published
  var collections: [VaultCollection] = []

  @Published
  var showSharedCollectionErrorMessage: Bool = false

  @Published
  var vaultState: VaultState = .default

  var isSharingDisabledForStarterUser: Bool {
    premiumStatusProvider.status.b2bStatus?.currentTeam?.isAdminOfAStarterTeam == false
      && premiumStatusProvider.status.isConcernedByStarterPlanSharingLimit
  }

  var isSharingDisabled: Bool {
    userSpacesService.configuration.currentTeam?.teamInfo.sharingDisabled == true
  }

  var isAdditionRestrictedByFrozenAccount: Bool {
    return vaultState == .frozen
  }

  @Published
  var viewState: ViewSate = .loading

  private var cancellables = Set<AnyCancellable>()

  private let collectionNamingViewModelFactory: CollectionNamingViewModel.Factory
  let collectionRowViewModelFactory: CollectionRowViewModel.Factory

  private let activityReporter: ActivityReporterProtocol
  private let capabilityService: CapabilityServiceProtocol
  private let vaultCollectionsStore: VaultCollectionsStore
  private let vaultCollectionDatabase: VaultCollectionDatabaseProtocol
  private let userSpacesService: UserSpacesService
  private let premiumStatusProvider: PremiumStatusProvider
  private let deeplinkingService: DeepLinkingServiceProtocol
  private let vaultStateService: VaultStateServiceProtocol
  private let vaultItemsStore: VaultItemsStore

  public init(
    activityReporter: ActivityReporterProtocol,
    capabilityService: CapabilityServiceProtocol,
    vaultCollectionsStore: VaultCollectionsStore,
    vaultCollectionDatabase: VaultCollectionDatabaseProtocol,
    userSpacesService: UserSpacesService,
    premiumStatusProvider: PremiumStatusProvider,
    vaultStateService: VaultStateServiceProtocol,
    deeplinkingService: DeepLinkingServiceProtocol,
    collectionNamingViewModelFactory: CollectionNamingViewModel.Factory,
    collectionRowViewModelFactory: CollectionRowViewModel.Factory,
    vaultItemsStore: VaultItemsStore
  ) {
    self.activityReporter = activityReporter
    self.capabilityService = capabilityService
    self.vaultCollectionsStore = vaultCollectionsStore
    self.vaultCollectionDatabase = vaultCollectionDatabase
    self.userSpacesService = userSpacesService
    self.premiumStatusProvider = premiumStatusProvider
    self.deeplinkingService = deeplinkingService
    self.vaultStateService = vaultStateService
    self.collectionNamingViewModelFactory = collectionNamingViewModelFactory
    self.collectionRowViewModelFactory = collectionRowViewModelFactory
    self.vaultItemsStore = vaultItemsStore

    registerPublishers()
  }

  private func registerPublishers() {
    vaultCollectionsStore
      .$collections
      .filter(by: userSpacesService.$configuration)
      .receive(on: DispatchQueue.main)
      .assign(to: &$collections)

    vaultStateService
      .vaultStatePublisher()
      .receive(on: DispatchQueue.main)
      .assign(to: &$vaultState)

    Publishers.CombineLatest(
      vaultItemsStore
        .$credentials
        .filter(by: userSpacesService.$configuration),

      vaultCollectionsStore
        .$collections
        .filter(by: userSpacesService.$configuration)
    )
    .receive(on: DispatchQueue.main)
    .sink { [weak self] credentialsList, collectionsList in
      guard let self else {
        return
      }

      if credentialsList.isEmpty && collectionsList.isEmpty {
        self.viewState = .emptyCredentialsList
      } else if collectionsList.isEmpty {
        self.viewState = .emptyCollectionsList
      } else {
        self.viewState = .loaded
      }
    }
    .store(in: &cancellables)
  }

  func isSharingDisabledByStarterPack(_ collection: VaultCollection) -> Bool {
    guard premiumStatusProvider.status.isConcernedByStarterPlanSharingLimit else {
      return false
    }

    guard premiumStatusProvider.status.b2bStatus?.currentTeam?.isAdminOfAStarterTeam == true else {
      return true
    }

    let sharedCollectionsCount = vaultCollectionsStore.collections.filter(\.isShared).count
    return premiumStatusProvider.status.hasSharingDisabledBecauseOfStarterPlanLimitation(
      alreadySharedCollectionsCount: sharedCollectionsCount) && !collection.isShared
  }

  func delete(_ collection: VaultCollection, with toast: ToastAction) {
    Task {
      do {
        try await vaultCollectionDatabase.delete(collection)
        toast(
          CoreL10n.KWVaultItem.Collections.deleted(collection.name),
          image: .ds.feedback.success.outlined)
      } catch {
        if collection.isShared {
          showSharedCollectionErrorMessage = true
        }
      }
    }
  }

  func shouldDisplayShareOption(for collection: VaultCollection) -> Bool {
    guard !collection.belongsToSpace(id: "") else {
      return false
    }

    guard !isSharingDisabledForStarterUser else {
      return true
    }

    return collection.sharingPermission != .limited
      && capabilityService.status(of: .collectionSharing).isAvailable
      && !isSharingDisabledByStarterPack(collection)
  }

  func redirectToFrozenPaywall() {
    deeplinkingService.handle(.frozenAccount)
  }

  func addPassword() {
    deeplinkingService.handle(.vault(.create(.credential)))
  }
}

extension CollectionsListViewModel {
  func makeCollectionNamingViewModel() -> CollectionNamingViewModel {
    collectionNamingViewModelFactory.make(mode: .addition)
  }

  func makeCollectionNamingViewModel(for collection: VaultCollection) -> CollectionNamingViewModel {
    collectionNamingViewModelFactory.make(mode: .edition(collection))
  }
}

extension CollectionsListViewModel {
  func reportCollectionSelection(_ collection: VaultCollection) {
    activityReporter.report(
      UserEvent.SelectCollection(
        collectionId: collection.id.rawValue,
        collectionSelectOrigin: .collectionList
      )
    )
  }
}

extension CollectionsListViewModel {
  var shouldShowSpace: Bool {
    userSpacesService.configuration.availableSpaces.count > 1
  }

  func userSpace(for collection: VaultCollection) -> UserSpace? {
    userSpacesService.configuration.virtualUserSpace(for: collection)
  }
}

extension CollectionsListViewModel {
  func isDeleteableOrEditable(_ collection: VaultCollection) -> Bool {
    guard collection.isShared else {
      return true
    }

    return collection.sharingPermission == .admin
  }
}

extension CollectionsListViewModel {
  private convenience init(
    collections: [VaultCollection],
    activityReporter: ActivityReporterProtocol,
    capabilityService: CapabilityServiceProtocol,
    vaultCollectionsStore: VaultCollectionsStore,
    vaultCollectionDatabase: VaultCollectionDatabaseProtocol,
    userSpacesService: UserSpacesService,
    premiumStatusProvider: PremiumStatusProvider,
    vaultStateService: VaultStateServiceProtocol,
    deeplinkingService: DeepLinkingServiceProtocol,
    collectionNamingViewModelFactory: CollectionNamingViewModel.Factory,
    collectionRowViewModelFactory: CollectionRowViewModel.Factory,
    vaultItemsStore: VaultItemsStore
  ) {
    self.init(
      activityReporter: activityReporter,
      capabilityService: capabilityService,
      vaultCollectionsStore: vaultCollectionsStore,
      vaultCollectionDatabase: vaultCollectionDatabase,
      userSpacesService: userSpacesService,
      premiumStatusProvider: premiumStatusProvider,
      vaultStateService: vaultStateService,
      deeplinkingService: deeplinkingService,
      collectionNamingViewModelFactory: collectionNamingViewModelFactory,
      collectionRowViewModelFactory: collectionRowViewModelFactory,
      vaultItemsStore: vaultItemsStore
    )
    self.collections = collections
  }

  public static var mock: CollectionsListViewModel {
    .init(
      collections: PersonalDataMock.Collections.all.map(VaultCollection.init(collection:)),
      activityReporter: .mock,
      capabilityService: CapabilityService.mock(),
      vaultCollectionsStore: MockVaultKitServicesContainer().vaultCollectionsStore,
      vaultCollectionDatabase: MockVaultKitServicesContainer().vaultCollectionDatabase,
      userSpacesService: MockVaultKitServicesContainer().userSpacesService,
      premiumStatusProvider: .mock(),
      vaultStateService: .mock(),
      deeplinkingService: MockVaultKitServicesContainer().deeplinkService,
      collectionNamingViewModelFactory: .init { mode in .mock(mode: mode) },
      collectionRowViewModelFactory: .init { collection in .mock(collection: collection) },
      vaultItemsStore: .mock()
    )
  }
}
