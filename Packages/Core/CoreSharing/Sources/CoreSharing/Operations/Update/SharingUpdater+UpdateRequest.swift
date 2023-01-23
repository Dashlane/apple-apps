import Foundation

extension SharingUpdater {
        struct UpdateRequest: Equatable {
                struct EntityRequest<T: Identifiable & Equatable>: Equatable {
            var entitiesToUpdate: [T]
            var idsToFetch: [T.ID]
            var idsToDelete: [T.ID]
            
            init(entitiesToUpdate: [T] = [],
                 idsToFetch: [T.ID] = [],
                 idsToDelete: [T.ID] = []) {
                self.entitiesToUpdate = entitiesToUpdate
                self.idsToFetch = idsToFetch
                self.idsToDelete = idsToDelete
            }
        }
        
        var itemGroups: EntityRequest<ItemGroup>
        var userGroups: EntityRequest<UserGroup>
        var items: EntityRequest<ItemContentCache>
        
        init(itemGroups: SharingUpdater.UpdateRequest.EntityRequest<ItemGroup> = .init(),
             userGroups: SharingUpdater.UpdateRequest.EntityRequest<UserGroup> = .init(),
             items: SharingUpdater.UpdateRequest.EntityRequest<ItemContentCache> = .init()) {
            self.itemGroups = itemGroups
            self.userGroups = userGroups
            self.items = items
        }
    }
}

extension SharingUpdater.UpdateRequest {
    static func +=(lhs: inout SharingUpdater.UpdateRequest, rhs: ParsedServerResponse) {
        lhs.userGroups.entitiesToUpdate += rhs.userGroups
        lhs.itemGroups.entitiesToUpdate += rhs.itemGroups
        lhs.items.entitiesToUpdate += rhs.items
    }
}

extension SharingUpdater.UpdateRequest {
    static func +=(lhs: inout Self, rhs: Self) {
        lhs.userGroups += rhs.userGroups
        lhs.itemGroups += rhs.itemGroups
        lhs.items += rhs.items
    }
    
    var isEmpty: Bool {
        userGroups.isEmpty
        && itemGroups.isEmpty
        && items.isEmpty
    }
}

extension SharingUpdater.UpdateRequest.EntityRequest {
    static func +=(lhs: inout Self, rhs: Self) {
        lhs.entitiesToUpdate += rhs.entitiesToUpdate
        lhs.idsToFetch += rhs.idsToFetch
        lhs.idsToDelete += rhs.idsToDelete
    }
    
    var isEmpty: Bool {
        entitiesToUpdate.isEmpty
        && idsToFetch.isEmpty
        && idsToDelete.isEmpty
    }
}


extension SharingUpdater.UpdateRequest {
        init(error: SharingInvalidActionError) {
        self.init()
        switch error.type {
        case .item:
            items.idsToFetch.append(error.id)
        case .itemGroup:
            itemGroups.idsToFetch.append(error.id)
        case .userGroup:
            userGroups.idsToFetch.append(error.id)
        }
    }
}
