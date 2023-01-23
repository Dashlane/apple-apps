import Foundation

extension SharingUpdater {
                func update(from summary: SharingSummary) async throws  {
        let localSummary = try database.fetchSummary()
        try await update(for: .init(remoteSummary: summary, localSummary: localSummary))
    }
}

extension SharingUpdater.UpdateRequest {
    init(remoteSummary: SharingSummary, localSummary: SharingSummary) {
        let itemGroupsDiff = localSummary.itemGroups.difference(from: remoteSummary.itemGroups)
        let userGroupsDiff = localSummary.userGroups.difference(from: remoteSummary.userGroups)
        let itemsDiff = localSummary.items.difference(from: remoteSummary.items)

        self.init(itemGroups: .init(idsToFetch: itemGroupsDiff.insertedOrUpdatedKeys, idsToDelete: itemGroupsDiff.deletedKeys),
                  userGroups: .init(idsToFetch: userGroupsDiff.insertedOrUpdatedKeys, idsToDelete: userGroupsDiff.deletedKeys),
                  items: .init(idsToFetch: itemsDiff.insertedOrUpdatedKeys, idsToDelete: itemsDiff.deletedKeys))
    
    }
}

fileprivate extension Dictionary where Key: Hashable, Value: Equatable  {
     func difference(from dict: [Key: Value]) -> (insertedOrUpdatedKeys: [Key], deletedKeys: [Key]){
        let updatedKeys = filter { (key: Key, value: Value) in
            guard let otherValue = dict[key] else {
                return false
            }
            
            return value != otherValue
        }.keys
        
        let keys = Set(keys)
        let otherKeys = Set(dict.keys)
        let insertedKeys = otherKeys.subtracting(keys)
        let deletedKeys = keys.subtracting(otherKeys)
        
        return (insertedOrUpdatedKeys: Array(updatedKeys) + insertedKeys, deletedKeys: Array(deletedKeys))
    }
}
