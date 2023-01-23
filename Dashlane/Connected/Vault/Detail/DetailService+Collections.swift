import CorePersonalData
import Foundation

extension DetailService {
    func addItemToCollection(named: String) {
        if let collection = allCollections.first(where: { $0.name == named }) {
            addItem(to: collection)
        } else {
            createAndAddItemToCollection(named: named)
        }
    }

    private func createAndAddItemToCollection(named: String) {
        var newCollection = VaultCollection(name: named)
        newCollection.insert(item)

        allCollections.append(newCollection)
        collections.append(newCollection)
    }

    private func addItem(to collection: VaultCollection) {
        guard !collection.contains(item) else { return }

        var collectionCopy = collection
        collectionCopy.insert(item)

        guard let index = allCollections.firstIndex(where: { $0.id == collectionCopy.id }) else {
            assertionFailure("Collection \(collectionCopy) does not exist")
            return
        }
        allCollections[index] = collectionCopy
        collections.append(collectionCopy)
    }

    func removeItem(from collection: VaultCollection) {
        allCollections.remove(item, from: collection)
        collections.removeAll(where: { $0.id == collection.id })
    }
}
