import Foundation
import DashTypes
import CyrilKit

struct SharingKeysHandler {
    let sharingKeysStore: SharingKeysStore
    let uploadContentService: UploadContentService

    public init(sharingKeysStore: SharingKeysStore,
                apiClient: DeprecatedCustomAPIClient) {
        self.sharingKeysStore = sharingKeysStore
        self.uploadContentService = UploadContentService(apiClient: apiClient)
    }

    func callAsFunction(_ rawSharingKeys: RawSharingKeys?, syncTimestamp timestamp: Timestamp) async throws -> Timestamp? {
        if let sharingKeys = SharingKeys(rawSharingKeys) {
            await sharingKeysStore.save(sharingKeys)
            return nil
        } else if await sharingKeysStore.needsKey {
            let keys = try AsymmetricKeyPair.makeAccountDefaultKeyPair()
            let privateKeyCryptoEngine = sharingKeysStore.privateKeyRemoteCryptoEngine
            let sharingKeys = try keys.makeSharingKeys(privateKeyCryptoEngine: privateKeyCryptoEngine)

            let output = try await uploadContentService.upload(.init(timestamp: timestamp, sharingKeys: sharingKeys, transactions: []))
            await self.sharingKeysStore.save(keys)
            return output.timestamp
        } else {
            return nil
        }
    }
}
