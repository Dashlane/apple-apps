import AuthenticationServices
import AutofillKit
import Combine
import CoreFeature
import CorePersonalData
import CoreTypes
import Foundation
import LogFoundation
import Logger
import VaultKit

extension AutofillStateService {
  convenience init(
    vaultItemsStore: VaultItemsStore,
    cryptoEngine: CryptoEngine,
    vaultStateService: VaultStateServiceProtocol,
    logger: Logger,
    snapshotFolderURL: URL
  ) {
    self.init(
      credentialsPublisher: vaultItemsStore.$credentials,
      passkeysPublisher: vaultItemsStore.$passkeys,
      cryptoEngine: cryptoEngine,
      vaultStateService: vaultStateService,
      logger: logger,
      snapshotFolderURL: snapshotFolderURL
    )
  }
}
