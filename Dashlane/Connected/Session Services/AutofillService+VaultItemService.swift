import AuthenticationServices
import AutofillKit
import Combine
import CorePersonalData
import DashTypes
import Foundation
import Logger
import VaultKit

extension AutofillService {
  convenience init(
    vaultItemsStore: VaultItemsStore,
    cryptoEngine: CryptoEngine,
    logger: Logger,
    snapshotFolderURL: URL
  ) {
    self.init(
      channel: .fromApp,
      credentialsPublisher: vaultItemsStore.$credentials,
      passkeysPublisher: vaultItemsStore.$passkeys,
      cryptoEngine: cryptoEngine,
      logger: logger,
      snapshotFolderURL: snapshotFolderURL
    )
  }
}
