import AuthenticationServices
import AutofillKit
import Combine
import CoreFeature
import CorePersonalData
import DashTypes
import Foundation
import Logger
import VaultKit

extension AutofillService {
  convenience init(
    vaultItemsStore: VaultItemsStore,
    cryptoEngine: CryptoEngine,
    vaultStateService: VaultStateServiceProtocol,
    logger: Logger,
    snapshotFolderURL: URL
  ) {
    self.init(
      channel: .fromApp,
      credentialsPublisher: vaultItemsStore.$credentials,
      passkeysPublisher: vaultItemsStore.$passkeys,
      cryptoEngine: cryptoEngine,
      vaultStateService: vaultStateService,
      logger: logger,
      snapshotFolderURL: snapshotFolderURL
    )
  }
}
