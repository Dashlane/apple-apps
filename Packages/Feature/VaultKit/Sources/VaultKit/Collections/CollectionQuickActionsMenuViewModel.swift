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

@MainActor
public final class CollectionQuickActionsMenuViewModel: ObservableObject, VaultKitServicesInjecting
{

  @Published
  var collection: VaultCollection

  @Published
  var showSharedCollectionErrorMessage: Bool = false

  @Published
  var isAdminDisabledByStarterPack: Bool = false

  @Published
  var isMemberDisabledByStarterPack: Bool = false

  var isSharingDisabled: Bool {
    userSpacesService.configuration.currentTeam?.teamInfo.sharingDisabled == true
  }

  private let logger: Logger
  private let activityReporter: ActivityReporterProtocol
  private let vaultCollectionsStore: VaultCollectionsStore
  private let vaultCollectionEditionService: VaultCollectionEditionService
  private let userSpacesService: UserSpacesService
  private let premiumStatusProvider: PremiumStatusProvider

  private let collectionNamingViewModelFactory: CollectionNamingViewModel.Factory

  private var cancellables: Set<AnyCancellable> = []
  private let queue: DispatchQueue = .init(
    label: "com.dashlane.collectionQuickActions", qos: .userInitiated)

  public init(
    collection: VaultCollection,
    logger: Logger,
    activityReporter: ActivityReporterProtocol,
    vaultCollectionsStore: VaultCollectionsStore,
    userSpacesService: UserSpacesService,
    premiumStatusProvider: PremiumStatusProvider,
    collectionNamingViewModelFactory: CollectionNamingViewModel.Factory,
    vaultCollectionEditionServiceFactory: VaultCollectionEditionService.Factory
  ) {
    self.collection = collection
    self.logger = logger
    self.activityReporter = activityReporter
    self.vaultCollectionsStore = vaultCollectionsStore
    self.userSpacesService = userSpacesService
    self.premiumStatusProvider = premiumStatusProvider
    self.collectionNamingViewModelFactory = collectionNamingViewModelFactory
    self.vaultCollectionEditionService = vaultCollectionEditionServiceFactory.make(
      collection: collection)

    self.registerPublishers()
  }

  private func registerPublishers() {
    vaultCollectionsStore
      .$collections
      .receive(on: queue)
      .compactMap { [weak self] collections in
        return collections.first(where: { $0.id == self?.collection.id })
      }
      .receive(on: DispatchQueue.main)
      .assign(to: &$collection)

    vaultCollectionsStore
      .$collections
      .receive(on: queue)
      .combineLatest(premiumStatusProvider.statusPublisher) { [weak self] (collections, status) in
        guard let self = self, status.isConcernedByStarterPlanSharingLimit else { return false }
        guard status.b2bStatus?.currentTeam?.isAdminOfAStarterTeam == true else { return false }

        let sharedCollectionsCount = collections.filter { $0.isShared }.count
        return status.hasSharingDisabledBecauseOfStarterPlanLimitation(
          alreadySharedCollectionsCount: sharedCollectionsCount) && !self.collection.isShared
      }
      .receive(on: DispatchQueue.main)
      .assign(to: &$isAdminDisabledByStarterPack)

    premiumStatusProvider
      .statusPublisher
      .map { status in
        guard status.isConcernedByStarterPlanSharingLimit else { return false }
        return status.b2bStatus?.currentTeam?.isAdminOfAStarterTeam == false
      }
      .receive(on: DispatchQueue.main)
      .assign(to: &$isMemberDisabledByStarterPack)
  }

  func deleteCollection(with toast: ToastAction) {
    Task {
      do {
        try await vaultCollectionEditionService.delete()
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

  func makeEditableCollectionNamingViewModel() -> CollectionNamingViewModel {
    collectionNamingViewModelFactory.make(mode: .edition(collection))
  }
}

extension CollectionQuickActionsMenuViewModel {
  var isDeleteableOrEditable: Bool {
    guard collection.isShared else {
      return true
    }

    return collection.sharingPermission == .admin
  }
}

extension CollectionQuickActionsMenuViewModel {
  func reportAppearance() {
    activityReporter.reportPageShown(.collectionQuickActionsDropdown)
  }

  func reportDeletionAppearance() {
    activityReporter.reportPageShown(.collectionDelete)
  }
}

extension CollectionQuickActionsMenuViewModel {
  public static func mock(collection: VaultCollection) -> CollectionQuickActionsMenuViewModel {
    .init(
      collection: collection,
      logger: .mock,
      activityReporter: .mock,
      vaultCollectionsStore: MockVaultKitServicesContainer().vaultCollectionsStore,
      userSpacesService: MockVaultKitServicesContainer().userSpacesService,
      premiumStatusProvider: .mock(),
      collectionNamingViewModelFactory: .init { .mock(mode: $0) },
      vaultCollectionEditionServiceFactory: .init { .mock($0) }
    )
  }
}
