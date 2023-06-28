import CoreSync
import Combine
import CoreSession
import DashTypes
import Foundation

public extension SharingKeysStore {
    init(session: Session, logger: Logger) async {
        await self.init(url: session.directory.url.appendingPathComponent("sharingKeys"),
                  localCryptoEngine: session.localCryptoEngine,
                  privateKeyRemoteCryptoEngine: session.remoteCryptoEngine,
                  logger: logger)
    }
}
