import Foundation

extension DetailService {
    func save() {
        let itemDidChange = item != originalItem
        let collectionsDidChange = allCollections != originalAllCollections

        guard mode.isAdding || itemDidChange || collectionsDidChange else {
            mode = .viewing
            return
        }
        do {
            if itemDidChange {
                try saveItem()
            }
            if collectionsDidChange {
                try saveCollections()
            }
        } catch {
            logger[.personalData].error("Error on save", error: error)
        }
    }

    private func saveItem() throws {
        try prepareForSaving()
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
        let diff = allCollections.difference(from: originalAllCollections)
        try diff.removals.forEach { removal in
            guard case .remove(_, let collection, _) = removal else { return }
            try vaultItemsService.delete(collection)
        }
        let savedCollections = try allCollections.map { try vaultItemsService.save($0) }
        originalAllCollections = savedCollections
        allCollections = savedCollections
        collections = savedCollections.filter(by: item)
    }

    func saveIfViewing() {
        guard mode == .viewing else { return }
        save()
    }
}
