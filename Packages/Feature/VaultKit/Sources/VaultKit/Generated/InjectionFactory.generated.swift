#if canImport(Combine)
import Combine
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

public protocol VaultKitServicesInjecting { }

#if os(iOS)
extension VaultKitServicesContainer {
        
        public func makeAddAttachmentButtonViewModel(editingItem: VaultItem, shouldDisplayRenameAlert: Bool = true, itemPublisher: AnyPublisher<VaultItem, Never>) -> AddAttachmentButtonViewModel {
            return AddAttachmentButtonViewModel(
                            documentStorageService: documentStorageService,
                            activityReporter: reporter,
                            featureService: vaultKitFeatureService,
                            editingItem: editingItem,
                            premiumService: vaultKitPremiumService,
                            shouldDisplayRenameAlert: shouldDisplayRenameAlert,
                            itemPublisher: itemPublisher
            )
        }
        
}

extension VaultKitServicesContainer {
        
        public func makeAttachmentRowViewModel(attachment: Attachment, attachmentPublisher: AnyPublisher<Attachment, Never>, editingItem: DocumentAttachable, deleteAction: @escaping (Attachment) -> Void) -> AttachmentRowViewModel {
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
        
        public func makeAttachmentsListViewModel(editingItem: VaultItem, itemPublisher: AnyPublisher<VaultItem, Never>) -> AttachmentsListViewModel {
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
        
        public func makeAttachmentsSectionViewModel(item: VaultItem, itemPublisher: AnyPublisher<VaultItem, Never>) -> AttachmentsSectionViewModel {
            return AttachmentsSectionViewModel(
                            vaultItemsService: vaultItemsService,
                            item: item,
                            documentStorageService: documentStorageService,
                            attachmentsListViewModelProvider: makeAttachmentsListViewModel,
                            makeAddAttachmentButtonViewModel: InjectedFactory(makeAddAttachmentButtonViewModel),
                            itemPublisher: itemPublisher
            )
        }
        
}
#endif

extension VaultKitServicesContainer {
        
        public func makeCollectionNamingViewModel(mode: CollectionNamingViewModel.Mode) -> CollectionNamingViewModel {
            return CollectionNamingViewModel(
                            mode: mode,
                            logger: logger,
                            activityReporter: reporter,
                            vaultItemsService: vaultItemsService,
                            teamSpacesService: vaultKitTeamSpacesServiceProcotol
            )
        }
        
}

extension VaultKitServicesContainer {
        
        public func makeCollectionQuickActionsMenuViewModel(collection: VaultCollection) -> CollectionQuickActionsMenuViewModel {
            return CollectionQuickActionsMenuViewModel(
                            collection: collection,
                            logger: logger,
                            activityReporter: reporter,
                            vaultItemsService: vaultItemsService,
                            collectionNamingViewModelFactory: InjectedFactory(makeCollectionNamingViewModel)
            )
        }
        
}

extension VaultKitServicesContainer {
        
        public func makeCollectionRowViewModel(collection: VaultCollection) -> CollectionRowViewModel {
            return CollectionRowViewModel(
                            collection: collection,
                            teamSpacesService: vaultKitTeamSpacesServiceProcotol,
                            vaultItemsService: vaultItemsService
            )
        }
        
}

extension VaultKitServicesContainer {
        
        public func makeCollectionsListViewModel() -> CollectionsListViewModel {
            return CollectionsListViewModel(
                            logger: logger,
                            activityReporter: reporter,
                            vaultItemsService: vaultItemsService,
                            teamSpacesService: vaultKitTeamSpacesServiceProcotol,
                            collectionNamingViewModelFactory: InjectedFactory(makeCollectionNamingViewModel),
                            collectionRowViewModelFactory: InjectedFactory(makeCollectionRowViewModel)
            )
        }
        
}

extension VaultKitServicesContainer {
        
        public func makeUserSpaceSwitcherViewModel() -> UserSpaceSwitcherViewModel {
            return UserSpaceSwitcherViewModel(
                            teamSpacesService: teamSpacesServiceProcotol,
                            activityReporter: reporter
            )
        }
        
}


#if os(iOS)
public typealias _AddAttachmentButtonViewModelFactory =  (
    _ editingItem: VaultItem,
    _ shouldDisplayRenameAlert: Bool,
    _ itemPublisher: AnyPublisher<VaultItem, Never>
) -> AddAttachmentButtonViewModel

public extension InjectedFactory where T == _AddAttachmentButtonViewModelFactory {
    
    func make(editingItem: VaultItem, shouldDisplayRenameAlert: Bool = true, itemPublisher: AnyPublisher<VaultItem, Never>) -> AddAttachmentButtonViewModel {
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


public typealias _AttachmentRowViewModelFactory =  (
    _ attachment: Attachment,
    _ attachmentPublisher: AnyPublisher<Attachment, Never>,
    _ editingItem: DocumentAttachable,
    _ deleteAction: @escaping (Attachment) -> Void
) -> AttachmentRowViewModel

public extension InjectedFactory where T == _AttachmentRowViewModelFactory {
    
    func make(attachment: Attachment, attachmentPublisher: AnyPublisher<Attachment, Never>, editingItem: DocumentAttachable, deleteAction: @escaping (Attachment) -> Void) -> AttachmentRowViewModel {
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


public typealias _AttachmentsListViewModelFactory =  (
    _ editingItem: VaultItem,
    _ itemPublisher: AnyPublisher<VaultItem, Never>
) -> AttachmentsListViewModel

public extension InjectedFactory where T == _AttachmentsListViewModelFactory {
    
    func make(editingItem: VaultItem, itemPublisher: AnyPublisher<VaultItem, Never>) -> AttachmentsListViewModel {
       return factory(
              editingItem,
              itemPublisher
       )
    }
}

extension AttachmentsListViewModel {
        public typealias Factory = InjectedFactory<_AttachmentsListViewModelFactory>
}


public typealias _AttachmentsSectionViewModelFactory =  (
    _ item: VaultItem,
    _ itemPublisher: AnyPublisher<VaultItem, Never>
) -> AttachmentsSectionViewModel

public extension InjectedFactory where T == _AttachmentsSectionViewModelFactory {
    
    func make(item: VaultItem, itemPublisher: AnyPublisher<VaultItem, Never>) -> AttachmentsSectionViewModel {
       return factory(
              item,
              itemPublisher
       )
    }
}

extension AttachmentsSectionViewModel {
        public typealias Factory = InjectedFactory<_AttachmentsSectionViewModelFactory>
}
#endif


public typealias _CollectionNamingViewModelFactory =  (
    _ mode: CollectionNamingViewModel.Mode
) -> CollectionNamingViewModel

public extension InjectedFactory where T == _CollectionNamingViewModelFactory {
    
    func make(mode: CollectionNamingViewModel.Mode) -> CollectionNamingViewModel {
       return factory(
              mode
       )
    }
}

extension CollectionNamingViewModel {
        public typealias Factory = InjectedFactory<_CollectionNamingViewModelFactory>
}


public typealias _CollectionQuickActionsMenuViewModelFactory =  (
    _ collection: VaultCollection
) -> CollectionQuickActionsMenuViewModel

public extension InjectedFactory where T == _CollectionQuickActionsMenuViewModelFactory {
    
    func make(collection: VaultCollection) -> CollectionQuickActionsMenuViewModel {
       return factory(
              collection
       )
    }
}

extension CollectionQuickActionsMenuViewModel {
        public typealias Factory = InjectedFactory<_CollectionQuickActionsMenuViewModelFactory>
}


public typealias _CollectionRowViewModelFactory =  (
    _ collection: VaultCollection
) -> CollectionRowViewModel

public extension InjectedFactory where T == _CollectionRowViewModelFactory {
    
    func make(collection: VaultCollection) -> CollectionRowViewModel {
       return factory(
              collection
       )
    }
}

extension CollectionRowViewModel {
        public typealias Factory = InjectedFactory<_CollectionRowViewModelFactory>
}


public typealias _CollectionsListViewModelFactory =  (
) -> CollectionsListViewModel

public extension InjectedFactory where T == _CollectionsListViewModelFactory {
    
    func make() -> CollectionsListViewModel {
       return factory(
       )
    }
}

extension CollectionsListViewModel {
        public typealias Factory = InjectedFactory<_CollectionsListViewModelFactory>
}


public typealias _UserSpaceSwitcherViewModelFactory =  (
) -> UserSpaceSwitcherViewModel

public extension InjectedFactory where T == _UserSpaceSwitcherViewModelFactory {
    
    func make() -> UserSpaceSwitcherViewModel {
       return factory(
       )
    }
}

extension UserSpaceSwitcherViewModel {
        public typealias Factory = InjectedFactory<_UserSpaceSwitcherViewModelFactory>
}

