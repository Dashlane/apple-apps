import CyrilKit
import DashTypes
import DashlaneAPI
import Foundation

struct SharingKeysHandler {
  let sharingKeysStore: SharingKeysStore
  let apiClient: UserDeviceAPIClient
  let logger: Logger

  public init(
    sharingKeysStore: SharingKeysStore,
    apiClient: UserDeviceAPIClient,
    logger: Logger
  ) {
    self.sharingKeysStore = sharingKeysStore
    self.apiClient = apiClient
    self.logger = logger
  }

  func callAsFunction(for sharingData: SharingData, syncTimestamp timestamp: Timestamp) async
    -> Timestamp?
  {
    do {
      if let sharingKeys = sharingData.keys, !sharingKeys.publicKey.isEmpty,
        !sharingKeys.privateKey.isEmpty
      {
        try await sharingKeysStore.save(sharingKeys)
        return nil
      } else if await sharingKeysStore.needsKey {
        return try await createNewKeysAndUpload(from: timestamp)
      }
    } catch {
      logger.fatal("Cannot handle sharing keys", error: error)
    }

    return nil
  }

  private func createNewKeysAndUpload(from timestamp: Timestamp) async throws -> Timestamp? {
    let keys = try AsymmetricKeyPair.makeAccountDefaultKeyPair()
    let privateKeyCryptoEngine = sharingKeysStore.privateKeyRemoteCryptoEngine
    let sharingKeys = try keys.makeSharingKeys(privateKeyCryptoEngine: privateKeyCryptoEngine)

    let output = try await apiClient.sync.uploadContent(
      timestamp: Int(timestamp.rawValue),
      transactions: [],
      sharingKeys: sharingKeys)

    await self.sharingKeysStore.save(keys)
    return Timestamp(output.timestamp)
  }
}
