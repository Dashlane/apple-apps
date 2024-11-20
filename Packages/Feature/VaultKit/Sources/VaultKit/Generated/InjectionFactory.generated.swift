#if canImport(Combine)
  import Combine
#endif
#if canImport(CoreActivityLogs)
  import CoreActivityLogs
#endif
#if canImport(CoreCategorizer)
  import CoreCategorizer
#endif
#if canImport(CoreFeature)
  import CoreFeature
#endif
#if canImport(CoreLocalization)
  import CoreLocalization
#endif
#if canImport(CoreMedia)
  import CoreMedia
#endif
#if canImport(CorePersonalData)
  import CorePersonalData
#endif
#if canImport(CorePremium)
  import CorePremium
#endif
#if canImport(CoreSession)
  import CoreSession
#endif
#if canImport(CoreSettings)
  import CoreSettings
#endif
#if canImport(CoreSharing)
  import CoreSharing
#endif
#if canImport(CoreSpotlight)
  import CoreSpotlight
#endif
#if canImport(CoreUserTracking)
  import CoreUserTracking
#endif
#if canImport(DashTypes)
  import DashTypes
#endif
#if canImport(DesignSystem)
  import DesignSystem
#endif
#if canImport(DocumentServices)
  import DocumentServices
#endif
#if canImport(Foundation)
  import Foundation
#endif
#if canImport(IconLibrary)
  import IconLibrary
#endif
#if canImport(Logger)
  import Logger
#endif
#if canImport(PDFKit)
  import PDFKit
#endif
#if canImport(QuickLook)
  import QuickLook
#endif
#if canImport(SwiftUI)
  import SwiftUI
#endif
#if canImport(UIDelight)
  import UIDelight
#endif

public protocol VaultKitServicesInjecting {}

extension VaultKitServicesContainer {

  public func makeAddAttachmentButtonViewModel(
    editingItem: VaultItem, shouldDisplayRenameAlert: Bool = true,
    itemPublisher: AnyPublisher<VaultItem, Never>
  ) -> AddAttachmentButtonViewModel {
    return AddAttachmentButtonViewModel(
      documentStorageService: documentStorageService,
      activityReporter: reporter,
      featureService: vaultKitFeatureService,
      editingItem: editingItem,
      capabilityService: capabilityService,
      shouldDisplayRenameAlert: shouldDisplayRenameAlert,
      itemPublisher: itemPublisher
    )
  }

}

extension VaultKitServicesContainer {

  public func makeAttachmentRowViewModel(
    attachment: Attachment, attachmentPublisher: AnyPublisher<Attachment, Never>,
    editingItem: DocumentAttachable, deleteAction: @escaping (Attachment) -> Void
  ) -> AttachmentRowViewModel {
    return AttachmentRowViewModel(
      attachment: attachment,
      attachmentPublisher: attachmentPublisher,
      editingItem: editingItem,
      database: database,
      documentStorageService: documentStorageService,
      deleteAction: deleteAction
    )
  }

}

extension VaultKitServicesContainer {

  public func makeAttachmentsListViewModel(
    editingItem: VaultItem, itemPublisher: AnyPublisher<VaultItem, Never>
  ) -> AttachmentsListViewModel {
    return AttachmentsListViewModel(
      documentStorageService: documentStorageService,
      activityReporter: reporter,
      database: database,
      editingItem: editingItem,
      makeAddAttachmentButtonViewModel: InjectedFactory(makeAddAttachmentButtonViewModel),
      itemPublisher: itemPublisher
    )
  }

}

extension VaultKitServicesContainer {

  public func makeAttachmentsSectionViewModel(
    item: VaultItem, itemPublisher: AnyPublisher<VaultItem, Never>
  ) -> AttachmentsSectionViewModel {
    return AttachmentsSectionViewModel(
      item: item,
      documentStorageService: documentStorageService,
      vaultCollectionsStore: vaultServicesSuit.vaultCollectionsStore,
      attachmentsListViewModelProvider: makeAttachmentsListViewModel,
      makeAddAttachmentButtonViewModel: InjectedFactory(makeAddAttachmentButtonViewModel),
      itemPublisher: itemPublisher
    )
  }

}

extension VaultKitServicesContainer {
  @MainActor
  public func makeCollectionNamingViewModel(mode: CollectionNamingViewModel.Mode)
    -> CollectionNamingViewModel
  {
    return CollectionNamingViewModel(
      mode: mode,
      logger: logger,
      activityReporter: reporter,
      vaultCollectionDatabase: vaultServicesSuit.vaultCollectionDatabase,
      vaultCollectionsStore: vaultServicesSuit.vaultCollectionsStore,
      userSpacesService: userSpacesService,
      vaultCollectionEditionServiceFactory: InjectedFactory(makeVaultCollectionEditionService)
    )
  }

}

extension VaultKitServicesContainer {
  @MainActor
  public func makeCollectionQuickActionsMenuViewModel(collection: VaultCollection)
    -> CollectionQuickActionsMenuViewModel
  {
    return CollectionQuickActionsMenuViewModel(
      collection: collection,
      logger: logger,
      activityReporter: reporter,
      vaultCollectionsStore: vaultServicesSuit.vaultCollectionsStore,
      userSpacesService: userSpacesService,
      premiumStatusProvider: premiumStatusProvider,
      collectionNamingViewModelFactory: InjectedFactory(makeCollectionNamingViewModel),
      vaultCollectionEditionServiceFactory: InjectedFactory(makeVaultCollectionEditionService)
    )
  }

}

extension VaultKitServicesContainer {
  @MainActor
  public func makeCollectionRowViewModel(collection: VaultCollection) -> CollectionRowViewModel {
    return CollectionRowViewModel(
      collection: collection,
      userSpacesService: userSpacesService
    )
  }

}

extension VaultKitServicesContainer {
  @MainActor
  public func makeCollectionsListViewModel() -> CollectionsListViewModel {
    return CollectionsListViewModel(
      activityReporter: reporter,
      capabilityService: capabilityService,
      vaultCollectionsStore: vaultServicesSuit.vaultCollectionsStore,
      vaultCollectionDatabase: vaultServicesSuit.vaultCollectionDatabase,
      userSpacesService: userSpacesService,
      premiumStatusProvider: premiumStatusProvider,
      vaultStateService: vaultKitVaultStateService,
      deeplinkingService: vaultKitDeepLinkingService,
      collectionNamingViewModelFactory: InjectedFactory(makeCollectionNamingViewModel),
      collectionRowViewModelFactory: InjectedFactory(makeCollectionRowViewModel)
    )
  }

}

extension VaultKitServicesContainer {

  internal func makeDefaultVaultItemsService(login: Login, categorizer: CategorizerProtocol)
    -> DefaultVaultItemsService
  {
    return DefaultVaultItemsService(
      login: login,
      logger: logger,
      database: database,
      userSpacesService: userSpacesService,
      categorizer: categorizer
    )
  }

}

extension VaultKitServicesContainer {

  public func makeDuplicateItemsViewModel() -> DuplicateItemsViewModel {
    return DuplicateItemsViewModel(
      vaultItemDatabase: vaultServicesSuit.vaultItemDatabase,
      vaultItemIconViewModelFactory: InjectedFactory(makeVaultItemIconViewModel),
      userSpacesService: userSpacesService
    )
  }

}

extension VaultKitServicesContainer {

  public func makePrefilledCredentialsProvider(
    login: Login, urlDecoder: PersonalDataURLDecoderProtocol
  ) -> PrefilledCredentialsProvider {
    return PrefilledCredentialsProvider(
      login: login,
      urlDecoder: urlDecoder
    )
  }

}

extension VaultKitServicesContainer {
  @MainActor
  public func makeUserSpaceSwitcherViewModel() -> UserSpaceSwitcherViewModel {
    return UserSpaceSwitcherViewModel(
      userSpacesService: userSpacesService,
      activityReporter: reporter
    )
  }

}

extension VaultKitServicesContainer {

  public func makeVaultCollectionDatabase() -> VaultCollectionDatabase {
    return VaultCollectionDatabase(
      logger: logger,
      database: database,
      sharingService: vaultKitSharingService,
      userSpacesService: userSpacesService,
      activityReporter: reporter,
      activityLogsService: activityLogsService
    )
  }

}

extension VaultKitServicesContainer {

  public func makeVaultCollectionEditionService(collection: VaultCollection)
    -> VaultCollectionEditionService
  {
    return VaultCollectionEditionService(
      collection: collection,
      logger: logger,
      activityReporter: reporter,
      activityLogsService: activityLogsService,
      vaultCollectionDatabase: vaultServicesSuit.vaultCollectionDatabase,
      vaultCollectionsStore: vaultServicesSuit.vaultCollectionsStore,
      sharingService: vaultKitSharingService
    )
  }

}

extension VaultKitServicesContainer {

  public func makeVaultItemDatabase() -> VaultItemDatabase {
    return VaultItemDatabase(
      logger: logger,
      database: database,
      sharingService: vaultKitSharingServiceHandler,
      featureService: vaultKitFeatureService,
      userSpacesService: userSpacesService,
      activityLogsService: activityLogsService
    )
  }

}

extension VaultKitServicesContainer {

  public func makeVaultItemIconViewModel(item: VaultItem) -> VaultItemIconViewModel {
    return VaultItemIconViewModel(
      item: item,
      domainIconLibrary: domainIconLibrary
    )
  }

}

extension VaultKitServicesContainer {

  internal func makeVaultItemsSpotlightService(spotlightIndexer: SpotlightIndexer?)
    -> VaultItemsSpotlightService
  {
    return VaultItemsSpotlightService(
      vaultItemsStore: vaultServicesSuit.vaultItemsStore,
      userSettings: vaultKitUserSettings,
      spotlightIndexer: spotlightIndexer
    )
  }

}

public typealias _AddAttachmentButtonViewModelFactory = (
  _ editingItem: VaultItem,
  _ shouldDisplayRenameAlert: Bool,
  _ itemPublisher: AnyPublisher<VaultItem, Never>
) -> AddAttachmentButtonViewModel

extension InjectedFactory where T == _AddAttachmentButtonViewModelFactory {

  public func make(
    editingItem: VaultItem, shouldDisplayRenameAlert: Bool = true,
    itemPublisher: AnyPublisher<VaultItem, Never>
  ) -> AddAttachmentButtonViewModel {
    return factory(
      editingItem,
      shouldDisplayRenameAlert,
      itemPublisher
    )
  }
}

extension AddAttachmentButtonViewModel {
  public typealias Factory = InjectedFactory<_AddAttachmentButtonViewModelFactory>
}

public typealias _AttachmentRowViewModelFactory = (
  _ attachment: Attachment,
  _ attachmentPublisher: AnyPublisher<Attachment, Never>,
  _ editingItem: DocumentAttachable,
  _ deleteAction: @escaping (Attachment) -> Void
) -> AttachmentRowViewModel

extension InjectedFactory where T == _AttachmentRowViewModelFactory {

  public func make(
    attachment: Attachment, attachmentPublisher: AnyPublisher<Attachment, Never>,
    editingItem: DocumentAttachable, deleteAction: @escaping (Attachment) -> Void
  ) -> AttachmentRowViewModel {
    return factory(
      attachment,
      attachmentPublisher,
      editingItem,
      deleteAction
    )
  }
}

extension AttachmentRowViewModel {
  public typealias Factory = InjectedFactory<_AttachmentRowViewModelFactory>
}

public typealias _AttachmentsListViewModelFactory = (
  _ editingItem: VaultItem,
  _ itemPublisher: AnyPublisher<VaultItem, Never>
) -> AttachmentsListViewModel

extension InjectedFactory where T == _AttachmentsListViewModelFactory {

  public func make(editingItem: VaultItem, itemPublisher: AnyPublisher<VaultItem, Never>)
    -> AttachmentsListViewModel
  {
    return factory(
      editingItem,
      itemPublisher
    )
  }
}

extension AttachmentsListViewModel {
  public typealias Factory = InjectedFactory<_AttachmentsListViewModelFactory>
}

public typealias _AttachmentsSectionViewModelFactory = (
  _ item: VaultItem,
  _ itemPublisher: AnyPublisher<VaultItem, Never>
) -> AttachmentsSectionViewModel

extension InjectedFactory where T == _AttachmentsSectionViewModelFactory {

  public func make(item: VaultItem, itemPublisher: AnyPublisher<VaultItem, Never>)
    -> AttachmentsSectionViewModel
  {
    return factory(
      item,
      itemPublisher
    )
  }
}

extension AttachmentsSectionViewModel {
  public typealias Factory = InjectedFactory<_AttachmentsSectionViewModelFactory>
}

public typealias _CollectionNamingViewModelFactory = @MainActor (
  _ mode: CollectionNamingViewModel.Mode
) -> CollectionNamingViewModel

extension InjectedFactory where T == _CollectionNamingViewModelFactory {
  @MainActor
  public func make(mode: CollectionNamingViewModel.Mode) -> CollectionNamingViewModel {
    return factory(
      mode
    )
  }
}

extension CollectionNamingViewModel {
  public typealias Factory = InjectedFactory<_CollectionNamingViewModelFactory>
}

public typealias _CollectionQuickActionsMenuViewModelFactory = @MainActor (
  _ collection: VaultCollection
) -> CollectionQuickActionsMenuViewModel

extension InjectedFactory where T == _CollectionQuickActionsMenuViewModelFactory {
  @MainActor
  public func make(collection: VaultCollection) -> CollectionQuickActionsMenuViewModel {
    return factory(
      collection
    )
  }
}

extension CollectionQuickActionsMenuViewModel {
  public typealias Factory = InjectedFactory<_CollectionQuickActionsMenuViewModelFactory>
}

public typealias _CollectionRowViewModelFactory = @MainActor (
  _ collection: VaultCollection
) -> CollectionRowViewModel

extension InjectedFactory where T == _CollectionRowViewModelFactory {
  @MainActor
  public func make(collection: VaultCollection) -> CollectionRowViewModel {
    return factory(
      collection
    )
  }
}

extension CollectionRowViewModel {
  public typealias Factory = InjectedFactory<_CollectionRowViewModelFactory>
}

public typealias _CollectionsListViewModelFactory = @MainActor (
) -> CollectionsListViewModel

extension InjectedFactory where T == _CollectionsListViewModelFactory {
  @MainActor
  public func make() -> CollectionsListViewModel {
    return factory()
  }
}

extension CollectionsListViewModel {
  public typealias Factory = InjectedFactory<_CollectionsListViewModelFactory>
}

internal typealias _DefaultVaultItemsServiceFactory = (
  _ login: Login,
  _ categorizer: CategorizerProtocol
) -> DefaultVaultItemsService

extension InjectedFactory where T == _DefaultVaultItemsServiceFactory {

  func make(login: Login, categorizer: CategorizerProtocol) -> DefaultVaultItemsService {
    return factory(
      login,
      categorizer
    )
  }
}

extension DefaultVaultItemsService {
  internal typealias Factory = InjectedFactory<_DefaultVaultItemsServiceFactory>
}

public typealias _DuplicateItemsViewModelFactory = (
) -> DuplicateItemsViewModel

extension InjectedFactory where T == _DuplicateItemsViewModelFactory {

  public func make() -> DuplicateItemsViewModel {
    return factory()
  }
}

extension DuplicateItemsViewModel {
  public typealias Factory = InjectedFactory<_DuplicateItemsViewModelFactory>
}

public typealias _PrefilledCredentialsProviderFactory = (
  _ login: Login,
  _ urlDecoder: PersonalDataURLDecoderProtocol
) -> PrefilledCredentialsProvider

extension InjectedFactory where T == _PrefilledCredentialsProviderFactory {

  public func make(login: Login, urlDecoder: PersonalDataURLDecoderProtocol)
    -> PrefilledCredentialsProvider
  {
    return factory(
      login,
      urlDecoder
    )
  }
}

extension PrefilledCredentialsProvider {
  public typealias Factory = InjectedFactory<_PrefilledCredentialsProviderFactory>
}

public typealias _UserSpaceSwitcherViewModelFactory = @MainActor (
) -> UserSpaceSwitcherViewModel

extension InjectedFactory where T == _UserSpaceSwitcherViewModelFactory {
  @MainActor
  public func make() -> UserSpaceSwitcherViewModel {
    return factory()
  }
}

extension UserSpaceSwitcherViewModel {
  public typealias Factory = InjectedFactory<_UserSpaceSwitcherViewModelFactory>
}

public typealias _VaultCollectionDatabaseFactory = (
) -> VaultCollectionDatabase

extension InjectedFactory where T == _VaultCollectionDatabaseFactory {

  public func make() -> VaultCollectionDatabase {
    return factory()
  }
}

extension VaultCollectionDatabase {
  public typealias Factory = InjectedFactory<_VaultCollectionDatabaseFactory>
}

public typealias _VaultCollectionEditionServiceFactory = (
  _ collection: VaultCollection
) -> VaultCollectionEditionService

extension InjectedFactory where T == _VaultCollectionEditionServiceFactory {

  public func make(collection: VaultCollection) -> VaultCollectionEditionService {
    return factory(
      collection
    )
  }
}

extension VaultCollectionEditionService {
  public typealias Factory = InjectedFactory<_VaultCollectionEditionServiceFactory>
}

public typealias _VaultItemDatabaseFactory = (
) -> VaultItemDatabase

extension InjectedFactory where T == _VaultItemDatabaseFactory {

  public func make() -> VaultItemDatabase {
    return factory()
  }
}

extension VaultItemDatabase {
  public typealias Factory = InjectedFactory<_VaultItemDatabaseFactory>
}

public typealias _VaultItemIconViewModelFactory = (
  _ item: VaultItem
) -> VaultItemIconViewModel

extension InjectedFactory where T == _VaultItemIconViewModelFactory {

  public func make(item: VaultItem) -> VaultItemIconViewModel {
    return factory(
      item
    )
  }
}

extension VaultItemIconViewModel {
  public typealias Factory = InjectedFactory<_VaultItemIconViewModelFactory>
}

internal typealias _VaultItemsSpotlightServiceFactory = (
  _ spotlightIndexer: SpotlightIndexer?
) -> VaultItemsSpotlightService

extension InjectedFactory where T == _VaultItemsSpotlightServiceFactory {

  func make(spotlightIndexer: SpotlightIndexer?) -> VaultItemsSpotlightService {
    return factory(
      spotlightIndexer
    )
  }
}

extension VaultItemsSpotlightService {
  internal typealias Factory = InjectedFactory<_VaultItemsSpotlightServiceFactory>
}
