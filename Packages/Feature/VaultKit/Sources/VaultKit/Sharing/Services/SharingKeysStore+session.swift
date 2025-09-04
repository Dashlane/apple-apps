import Combine
import CoreSession
import CoreSync
import CoreTypes
import Foundation
import LogFoundation

extension SharingKeysStore {
  public init(session: Session, logger: Logger) async {
    await self.init(
      url: session.directory.url.appendingPathComponent("sharingKeys"),
      localCryptoEngine: session.localCryptoEngine,
      privateKeyRemoteCryptoEngine: session.remoteCryptoEngine,
      logger: logger)
  }
}
