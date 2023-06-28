import Foundation
import CyrilKit
import DashTypes

extension SharingUpdater {
                    struct PersonalDataUpdateRequest {
        let itemGroups: [ItemGroup]
        let contents: [ItemContentCache]

        var isEmpty: Bool {
            return itemGroups.isEmpty && contents.isEmpty
        }
    }

                                            func updatePersonalDataItems(for request: PersonalDataUpdateRequest, allItemGroups: [ItemGroup]) async throws {
        guard !request.isEmpty else {
            return
        }

        let insertedOrUpdatedItemContents = Dictionary(values: request.contents)
        let groupsForUpdatedItemContents = allItemGroups.filter(forItemIds: Set(insertedOrUpdatedItemContents.keys))
        let groups = request.itemGroups.union(groupsForUpdatedItemContents)

        let updates = groups.flatMap { group in
            return self.updates(for: group, insertedOrUpdatedItemContents: insertedOrUpdatedItemContents)
        }

        guard !updates.isEmpty else {
            return
        }

        try await personalDataDB.perform(updates)
        logger.debug("\(updates.count) update(s) performed on personal data DB")

                try database.save(updates.compactMap { insertedOrUpdatedItemContents[$0.id] })
    }

                                        private func updates(for group: ItemGroup, insertedOrUpdatedItemContents: [Identifier: ItemContentCache]) -> [SharingItemUpdate] {
        do {
            guard let groupKey = try groupKeyProvider.groupKey(for: group),
                  let itemState = try database.sharingMembers(forUserId: userId, in: group).computeItemState() else {
                return []
            }

            return try group.itemKeyPairs.map { itemKeyPair in
                try makeItemUpdate(itemKeyPair: itemKeyPair,
                                   itemState: itemState,
                                   itemContent: insertedOrUpdatedItemContents[itemKeyPair.id],
                                   groupKey: groupKey)
            }
        } catch {
            logger.fatal("Fail to create item updates for group with id \(group.id)", error: error)
            return []
        }
    }

                private func makeItemUpdate(itemKeyPair: ItemKeyPair,
                                itemState: SharingItemUpdate.State,
                                itemContent: ItemContentCache?,
                                groupKey: SymmetricKey) throws -> SharingItemUpdate {
        let transactionContent: Data?
                if let itemContent = itemContent {
            let itemKey =  try itemKeyPair.key(using: cryptoProvider.cryptoEngine(using: groupKey))
            transactionContent = try itemContent.content(using: cryptoProvider.cryptoEngine(using: itemKey))
        }
                else {
            transactionContent = nil
        }

        return SharingItemUpdate(id: itemKeyPair.id,
                                 state: itemState,
                                 transactionContent: transactionContent)
    }
}
