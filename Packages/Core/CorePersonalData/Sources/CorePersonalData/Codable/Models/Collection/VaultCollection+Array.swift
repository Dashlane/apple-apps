import DashTypes
import Foundation

extension Array where Element == VaultCollection {
                        public mutating func remove<T: PersonalDataCodable>(_ element: T, from collection: Element) {
        var collectionCopy = collection
        collectionCopy.remove(element)

        if collectionCopy.items.isEmpty {
            self.removeAll(where: { $0.id == collectionCopy.id })
        } else if let index = firstIndex(where: { $0.id == collectionCopy.id }) {
            self[index] = collectionCopy
        }
    }
}
