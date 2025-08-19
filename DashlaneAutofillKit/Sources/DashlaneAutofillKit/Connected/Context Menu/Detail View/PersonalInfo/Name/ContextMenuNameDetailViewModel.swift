import Combine
import CorePersonalData
import CoreSettings
import CoreTypes
import Foundation
import SwiftUI
import UserTrackingFoundation
import VaultKit

class ContextMenuNameDetailViewModel: ContextMenuDetailViewModelProtocol, SessionServicesInjecting {

  let service: DetailServiceContextMenuAutofill<Identity>
  let completion: (VaultItem, String) -> Void

  convenience init(
    vaultItemDatabase: VaultItemDatabaseProtocol,
    item: Identity,
    pasteboardService: PasteboardServiceProtocol,
    completion: @escaping (VaultItem, String) -> Void
  ) {
    self.init(
      service: .init(
        item: item, vaultItemDatabase: vaultItemDatabase, pasteboardService: pasteboardService),
      completion: completion)
  }

  init(
    service: DetailServiceContextMenuAutofill<Identity>,
    completion: @escaping (VaultItem, String) -> Void
  ) {
    self.service = service
    self.completion = completion
  }
}

extension ContextMenuNameDetailViewModel {
  static func mock() -> ContextMenuNameDetailViewModel {
    ContextMenuNameDetailViewModel(
      vaultItemDatabase: .mock(),
      item: PersonalDataMock.Identities.secret,
      pasteboardService: .mock(),
      completion: { _, _ in }
    )
  }
}
