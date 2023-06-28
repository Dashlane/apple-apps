#if os(iOS)
import CorePersonalData
import Foundation

extension DetailService {

    func updateCollectionsAfterSpaceChange() {
        removeItemFromAllCollections()
        updateUnusedCollections()
    }

    func updateAllCollections(with collections: [VaultCollection]) {
        let sortedCollections = collections.sortedByName()
        allVaultCollections = sortedCollections
        originalAllVaultCollections = sortedCollections
        updateUnusedCollections()
    }

    func updateCollections(with collections: [VaultCollection]) {
        let sortedCollections = collections.filter(spaceId: item.spaceId).sortedByName()
        self.itemCollections = sortedCollections
        originalItemCollections = sortedCollections
        updateUnusedCollections()
    }

    func updateUnusedCollections() {
        let allCollectionsInSpace = allVaultCollections.filter(spaceId: item.spaceId)
        unusedCollections = allCollectionsInSpace.difference(from: itemCollections).compactMap {
            guard case .insert(_, let collection, _) = $0 else { return nil }
            return collection
        }
    }

    func addItemToCollection(named: String) {
        if let collection = allVaultCollections.filter(spaceId: item.spaceId).first(where: { $0.name == named }) {
            addItem(to: collection)
        } else {
            createAndAddItemToCollection(named: named)
        }
    }

    private func createAndAddItemToCollection(named: String) {
        var newCollection = VaultCollection(name: named, spaceId: item.spaceId ?? "")
        newCollection.insert(item)

        allVaultCollections.append(newCollection)
        itemCollections.append(newCollection)

        allVaultCollections.sortByName()
        itemCollections.sortByName()
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

        itemCollections.sortByName()
    }

    func removeItem(from collection: VaultCollection) {
        allVaultCollections.remove(item, from: collection)
        itemCollections.removeAll(where: { $0.id == collection.id })

        if allVaultCollections.contains(where: { $0.id == collection.id }) {
            unusedCollections.append(collection)
            unusedCollections.sortByName()
        }
    }

    private func removeItemFromAllCollections() {
        itemCollections.forEach { removeItem(from: $0) }
    }
}
#endif
