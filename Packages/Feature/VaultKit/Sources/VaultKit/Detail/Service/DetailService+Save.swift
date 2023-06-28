#if os(iOS)
import Logger
import Foundation

public extension DetailService {
    func save() {
        let itemDidChange = item != originalItem
        let collectionsDidChange = allVaultCollections != originalAllVaultCollections

        guard mode.isAdding || itemDidChange || collectionsDidChange else {
            mode = .viewing
            return
        }
        do {
            try prepareForSaving()

            if itemDidChange {
                try saveItem()
            }

            if collectionsDidChange {
                try saveCollections()
            }

            eventPublisher.send(.save)
        } catch {
            logger[.personalData].error("Error on save", error: error)
        }
    }

    private func saveItem() throws {
        let now = Date()
        if mode.isAdding {
            item.creationDatetime = now
        }
        item.userModificationDatetime = now

        let savedItem = try vaultItemsService.save(item)
        logUpdate(of: savedItem)
        originalItem = savedItem
        item = savedItem
    }

    private func saveCollections() throws {
        let diff = allVaultCollections.difference(from: originalAllVaultCollections)
        try diff.removals.forEach { removal in
            guard case .remove(_, let collection, _) = removal else { return }
            try vaultItemsService.delete(collection)
        }
        let savedCollections = try allVaultCollections.map { try vaultItemsService.save($0) }
        logUpdate(originalCollections: originalItemCollections, collections: itemCollections)
        originalAllVaultCollections = savedCollections
        allVaultCollections = savedCollections
        let itemCollections = savedCollections.filter(by: item).filter(spaceId: item.spaceId)
        self.itemCollections = itemCollections
        self.originalItemCollections = itemCollections
    }

    func saveIfViewing() {
        guard mode == .viewing else { return }
        save()
    }
}
#endif
