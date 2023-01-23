import Foundation
import CoreSession
import CorePersonalData
import DashlaneAppKit
import DashTypes

final class PostCryptoSettingsChangeHandler: PostAccountCryptoChangeHandler {
    private(set) var syncService: SyncServiceProtocol

    init(syncService: SyncServiceProtocol) {
        self.syncService = syncService
    }

    func handle(_ session: Session, syncTimestamp: Timestamp) throws {
        syncService.lastSync = syncTimestamp
    }
}
