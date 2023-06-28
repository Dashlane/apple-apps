import Foundation
import CorePersonalData
import Combine
import CoreUserTracking
import DashlaneAppKit
import CoreSettings
import VaultKit
import DashTypes
import CoreSharing

class QuickActionsMenuViewModel: SessionServicesInjecting, MockVaultConnectedInjecting {
    let item: VaultItem
    let copyResultPublisher = PassthroughSubject<VaultItemRowModel.CopyResult, Never>()
    let sharingService: SharedVaultHandling
    let vaultItemsService: VaultItemsServiceProtocol
    let activityReporter: ActivityReporterProtocol
    let itemPasteboard: ItemPasteboardProtocol
    let origin: VaultItemRowModel.Origin
    let isSuggestedItem: Bool
    let shareFlowViewModelFactory: ShareFlowViewModel.Factory
    let sharingDeactivationReason: SharingDeactivationReason?

    var allVaultCollections: [VaultCollection]
    var unusedCollections: [VaultCollection]
    var itemCollections: [VaultCollection]

    private var subscriptions  = Set<AnyCancellable>()

    init(item: VaultItem,
         sharingService: SharedVaultHandling,
         accessControl: AccessControlProtocol,
         vaultItemsService: VaultItemsServiceProtocol,
         teamSpacesService: TeamSpacesService,
         activityReporter: ActivityReporterProtocol,
         shareFlowViewModelFactory: ShareFlowViewModel.Factory,
         origin: VaultItemRowModel.Origin,
         pasteboardService: PasteboardServiceProtocol,
         isSuggestedItem: Bool) {
        self.vaultItemsService = vaultItemsService
        self.sharingService = sharingService
        self.item = item
        self.shareFlowViewModelFactory = shareFlowViewModelFactory
        self.sharingDeactivationReason = teamSpacesService.businessTeamsInfo.isSharingDisabled() ? .b2bSharingDisabled : nil
        self.activityReporter = activityReporter
        self.origin = origin
        self.isSuggestedItem = isSuggestedItem
        self.itemPasteboard = ItemPasteboard(accessControl: accessControl, pasteboardService: pasteboardService)

        let allVaultCollections = vaultItemsService.collections
        self.allVaultCollections = allVaultCollections
        self.itemCollections = allVaultCollections.filter(spaceId: item.spaceId).filter(by: item)
        self.unusedCollections = allVaultCollections
            .filter(spaceId: item.spaceId)
            .difference(from: itemCollections)
            .compactMap {
                guard case .insert(_, let collection, _) = $0 else { return nil }
                return collection
            }
    }
}

extension QuickActionsMenuViewModel {
        func deleteBehaviour() async throws -> ItemDeleteBehaviour {
        try await sharingService.deleteBehaviour(for: item)
    }

    func delete() {
        vaultItemsService.delete(item)
        activityReporter.reportPageShown(.confirmItemDeletion)
    }

        func copy(fieldType: Definition.Field, valueToCopy: String) {
        guard sharingService.canCopyProperties(in: item) else {
            copyResultPublisher.send(.limitedRights)
            return
        }

        var lastUpdateOrigin: Set<LastUseUpdateOrigin> = [.default]
        if origin == .search {
            lastUpdateOrigin.insert(.search)
        }

        vaultItemsService.updateLastUseDate(of: [item], origin: lastUpdateOrigin)

        sendCopyUsageLog(fieldType: fieldType)

        itemPasteboard
            .copy(item, valueToCopy: valueToCopy)
            .map { $0 ? .success(fieldType: fieldType) : .authenticationDenied }
            .sink(receiveValue: copyResultPublisher.send)
            .store(in: &subscriptions)
    }

}

extension QuickActionsMenuViewModel {
    func addItemToCollection(named: String) throws {
        if let collection = allVaultCollections.filter(spaceId: item.spaceId).first(where: { $0.name == named }) {
            addItem(to: collection)
        } else {
            createAndAddItemToCollection(named: named)
        }
        try saveCollections()
    }

    private func createAndAddItemToCollection(named: String) {
        var newCollection = VaultCollection(name: named, spaceId: item.spaceId ?? "")
        newCollection.insert(item)

        allVaultCollections.append(newCollection)
        itemCollections.append(newCollection)
    }

    private func addItem(to collection: VaultCollection) {
        guard collection.belongsToSpace(id: item.spaceId) else {
            assertionFailure("Item that belongs to a space shouldn't be added to a collection that belongs to another space")
            return
        }
        guard !collection.contains(item) else { return }

        var collectionCopy = collection
        collectionCopy.insert(item)

        guard let index = allVaultCollections.firstIndex(where: { $0.id == collectionCopy.id }) else {
            assertionFailure("Collection \(collectionCopy) does not exist")
            return
        }
        allVaultCollections[index] = collectionCopy
        itemCollections.append(collectionCopy)
        unusedCollections.removeAll(where: { $0.id == collectionCopy.id })
    }

    func removeItem(from collections: [VaultCollection]) throws {
        collections.forEach { collection in
            allVaultCollections.remove(item, from: collection)
            itemCollections.removeAll(where: { $0.id == collection.id })
            unusedCollections.append(collection)
        }
        try saveCollections()
    }

    private func saveCollections() throws {
        let originalVaultCollections = vaultItemsService.collections
        let diff = allVaultCollections.difference(from: originalVaultCollections)
        try diff.removals.forEach { removal in
            guard case .remove(_, let collection, _) = removal else { return }
            try vaultItemsService.delete(collection)
        }
        let savedCollections = try allVaultCollections.map { try vaultItemsService.save($0) }
        let originalItemsCollections = originalVaultCollections.filter(by: item).filter(spaceId: item.spaceId)
        logUpdate(
            originalCollections: originalVaultCollections,
            originalItemCollections: originalItemsCollections,
            itemCollections: itemCollections
        )
        allVaultCollections = savedCollections
        itemCollections = savedCollections.filter(by: item).filter(spaceId: item.spaceId)
    }
}

extension QuickActionsMenuViewModel {
    func sendCopyUsageLog(fieldType: Definition.Field) {
        activityReporter.reportPageShown(.homeQuickActionsDropdown)
        let isProtected: Bool
        if let secureItem = item as? SecureItem {
            isProtected = secureItem.secured
        } else {
            isProtected = false
        }
        let item = item
        let highlight = origin.definitionHighlight(isSuggestedItem)
        activityReporter.report(UserEvent.CopyVaultItemField(field: fieldType,
                                                             highlight: highlight,
                                                             isProtected: isProtected,
                                                             itemId: item.userTrackingLogID,
                                                             itemType: item.vaultItemType))
        activityReporter.report(AnonymousEvent.CopyVaultItemField(domain: item.hashedDomainForLogs(),
                                                                  field: fieldType,
                                                                  itemType: item.vaultItemType))
    }

    private func log(itemAddedIn collection: VaultCollection, originalCollections: [VaultCollection]) {
        guard !collection.items.isEmpty else { return }

        if !originalCollections.contains(where: { $0.id == collection.id }) {
            activityReporter.report(UserEvent.UpdateCollection(
                action: .add,
                collectionId: collection.id.rawValue,
                isShared: collection.isShared,
                itemCount: 1)
            )
        }

        activityReporter.report(UserEvent.UpdateCollection(
            action: .addCredential,
            collectionId: collection.id.rawValue,
            isShared: collection.isShared,
            itemCount: 1)
        )
    }

    private func log(itemRemovedFrom collection: VaultCollection) {
        activityReporter.report(UserEvent.UpdateCollection(
            action: .deleteCredential,
            collectionId: collection.id.rawValue,
            isShared: collection.isShared,
            itemCount: 1)
        )
    }

    private func logUpdate(
        originalCollections: [VaultCollection],
        originalItemCollections: [VaultCollection],
        itemCollections: [VaultCollection]
    ) {
        itemCollections.difference(from: originalItemCollections).removals.forEach { removal in
            guard case .remove(_, let collection, _) = removal else { return }
            log(itemRemovedFrom: collection)
        }

        itemCollections.difference(from: originalItemCollections).insertions.forEach { insertion in
            guard case .insert(_, let collection, _) = insertion else { return }
            log(itemAddedIn: collection, originalCollections: originalCollections)
        }
    }

    func reportAppearance() {
        let vaultItemType = item.vaultItemType
        activityReporter.report(UserEvent.OpenVaultItemDropdown(dropdownType: .quickActions, itemType: vaultItemType))
    }
}

extension QuickActionsMenuViewModel {
    static func mock(item: VaultItem) -> QuickActionsMenuViewModel {
        QuickActionsMenuViewModel(
            item: item,
            sharingService: SharedVaultHandlerMock(),
            accessControl: FakeAccessControl(accept: true),
            vaultItemsService: MockServicesContainer().vaultItemsService,
            teamSpacesService: .mock(),
            activityReporter: .fake,
            shareFlowViewModelFactory: .init { _, _, _ in .mock() },
            origin: .home,
            pasteboardService: .mock(),
            isSuggestedItem: true
        )
    }
}
