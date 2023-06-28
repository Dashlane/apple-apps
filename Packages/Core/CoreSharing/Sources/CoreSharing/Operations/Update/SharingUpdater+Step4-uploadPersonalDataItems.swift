import Foundation
import DashTypes
import CyrilKit

extension SharingUpdater {
    private struct UploadOutput {
        let uploadId: String
        let content: ItemContentCache
    }

                                                        func uploadChangesFromPersonalData(in allItemGroups: [ItemGroup], nextRequest: inout UpdateRequest) async throws {
        let uploads = try await personalDataDB.pendingUploads()
        let uploadByIds = Dictionary(values: uploads)
                let groups = allItemGroups.filter(forItemIds: Set(uploadByIds.keys))

                var successfullUploads: [UploadOutput] = []

        for group in groups {
            guard let groupKey = try groupKeyProvider.groupKey(for: group) else {
                continue
            }
            for keyPair in group.itemKeyPairs {
                guard let upload = uploadByIds[keyPair.id] else {
                    continue
                }

                do {
                    let output = try await self.upload(upload, for: keyPair, in: group, groupKey: groupKey)
                    successfullUploads.append(output)
                } catch let error as SharingInvalidActionError {
                    nextRequest += UpdateRequest(error: error)
                    logger.error("item is not up to date")
                } catch {
                    logger.fatal("Cannot upload item \(keyPair.id) in group \(group.id)", error: error)
                    continue
                }
            }
        }

                try database.save(successfullUploads.map(\.content))

        try await personalDataDB.clearPendingUploads(withIds: successfullUploads.map(\.uploadId))
    }

                    private func upload(_ upload: SharingItemUpload, for keyPair: ItemKeyPair, in group: ItemGroup, groupKey: SymmetricKey) async throws -> UploadOutput {
                guard let timestamp = try database.fetchItemTimestamp(forId: keyPair.id) else {
            throw SharingUpdaterError.unknownSharedItem
        }

                let key = try keyPair.key(using: cryptoProvider.cryptoEngine(using: groupKey))
        let itemCryptoEngine = cryptoProvider.cryptoEngine(using: key)
        let encryptedContent = try upload.transactionContent.encrypt(using: itemCryptoEngine).base64EncodedString()

                let response = try await sharingClientAPI.updateItem(with: upload.id,
                                                             encryptedContent: encryptedContent,
                                                             timestamp: timestamp)

        guard let timestamp = response.items.first(where: { $0.id == upload.id })?.timestamp else {
            throw SharingUpdaterError.missingTimestampInServerResponse
        }

        let content = ItemContentCache(id: upload.id,
                                       timestamp: timestamp,
                                       encryptedContent: encryptedContent)

        return UploadOutput(uploadId: upload.uploadId, content: content)
    }
}
