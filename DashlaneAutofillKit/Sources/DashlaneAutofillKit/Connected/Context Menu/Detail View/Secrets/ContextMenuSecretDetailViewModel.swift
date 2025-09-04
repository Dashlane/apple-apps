import Combine
import CorePersonalData
import CoreSettings
import CoreTypes
import Foundation
import SwiftUI
import UserTrackingFoundation
import VaultKit

class ContextMenuSecretDetailViewModel: ContextMenuDetailViewModelProtocol, SessionServicesInjecting
{

  let service: DetailServiceContextMenuAutofill<Secret>
  let completion: (VaultItem, String) -> Void

  convenience init(
    vaultItemDatabase: VaultItemDatabaseProtocol,
    item: Secret,
    pasteboardService: PasteboardServiceProtocol,
    completion: @escaping (VaultItem, String) -> Void
  ) {
    self.init(
      service: .init(
        item: item, vaultItemDatabase: vaultItemDatabase, pasteboardService: pasteboardService),
      completion: completion)
  }

  init(
    service: DetailServiceContextMenuAutofill<Secret>,
    completion: @escaping (VaultItem, String) -> Void
  ) {
    self.service = service
    self.completion = completion
  }
}

extension ContextMenuSecretDetailViewModel {
  static func mock() -> ContextMenuSecretDetailViewModel {
    ContextMenuSecretDetailViewModel(
      vaultItemDatabase: .mock(),
      item: PersonalDataMock.Secrets.rsaKeyExample,
      pasteboardService: .mock(),
      completion: { _, _ in }
    )
  }
}
