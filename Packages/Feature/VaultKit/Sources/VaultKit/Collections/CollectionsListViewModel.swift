import CoreFeature
import CoreLocalization
import CorePersonalData
import CorePremium
import CoreUserTracking
import DashTypes
import DesignSystem
import Foundation

@MainActor
public final class CollectionsListViewModel: ObservableObject, VaultKitServicesInjecting {

  @Published
  var collections: [VaultCollection] = []

  @Published
  var showSharedCollectionErrorMessage: Bool = false

  var isSharingDisabledForStarterUser: Bool {
    premiumStatusProvider.status.b2bStatus?.currentTeam?.isAdminOfAStarterTeam == false
      && premiumStatusProvider.status.isConcernedByStarterPlanSharingLimit
  }

  var isSharingDisabled: Bool {
    userSpacesService.configuration.currentTeam?.teamInfo.sharingDisabled == true
  }

  private let collectionNamingViewModelFactory: CollectionNamingViewModel.Factory
  let collectionRowViewModelFactory: CollectionRowViewModel.Factory

  private let activityReporter: ActivityReporterProtocol
  private let capabilityService: CapabilityServiceProtocol
  private let vaultCollectionsStore: VaultCollectionsStore
  private let vaultCollectionDatabase: VaultCollectionDatabaseProtocol
  private let userSpacesService: UserSpacesService
  private let premiumStatusProvider: PremiumStatusProvider

  public init(
    activityReporter: ActivityReporterProtocol,
    capabilityService: CapabilityServiceProtocol,
    vaultCollectionsStore: VaultCollectionsStore,
    vaultCollectionDatabase: VaultCollectionDatabaseProtocol,
    userSpacesService: UserSpacesService,
    premiumStatusProvider: PremiumStatusProvider,
    collectionNamingViewModelFactory: CollectionNamingViewModel.Factory,
    collectionRowViewModelFactory: CollectionRowViewModel.Factory
  ) {
    self.activityReporter = activityReporter
    self.capabilityService = capabilityService
    self.vaultCollectionsStore = vaultCollectionsStore
    self.vaultCollectionDatabase = vaultCollectionDatabase
    self.userSpacesService = userSpacesService
    self.premiumStatusProvider = premiumStatusProvider
    self.collectionNamingViewModelFactory = collectionNamingViewModelFactory
    self.collectionRowViewModelFactory = collectionRowViewModelFactory

    registerPublishers()
  }

  private func registerPublishers() {
    vaultCollectionsStore
      .$collections
      .filter(by: userSpacesService.$configuration)
      .receive(on: DispatchQueue.main)
      .assign(to: &$collections)
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
          L10n.Core.KWVaultItem.Collections.deleted(collection.name),
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
    collectionNamingViewModelFactory: CollectionNamingViewModel.Factory,
    collectionRowViewModelFactory: CollectionRowViewModel.Factory
  ) {
    self.init(
      activityReporter: activityReporter,
      capabilityService: capabilityService,
      vaultCollectionsStore: vaultCollectionsStore,
      vaultCollectionDatabase: vaultCollectionDatabase,
      userSpacesService: userSpacesService,
      premiumStatusProvider: premiumStatusProvider,
      collectionNamingViewModelFactory: collectionNamingViewModelFactory,
      collectionRowViewModelFactory: collectionRowViewModelFactory
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
      collectionNamingViewModelFactory: .init { mode in .mock(mode: mode) },
      collectionRowViewModelFactory: .init { collection in .mock(collection: collection) }
    )
  }
}
