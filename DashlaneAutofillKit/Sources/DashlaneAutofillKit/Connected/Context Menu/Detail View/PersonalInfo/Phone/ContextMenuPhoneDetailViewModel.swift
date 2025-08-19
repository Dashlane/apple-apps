import Combine
import CorePersonalData
import CoreSettings
import CoreTypes
import Foundation
import SwiftUI
import UserTrackingFoundation
import VaultKit

class ContextMenuPhoneDetailViewModel: ContextMenuDetailViewModelProtocol, SessionServicesInjecting
{

  let service: DetailServiceContextMenuAutofill<Phone>
  let completion: (VaultItem, String) -> Void

  convenience init(
    vaultItemDatabase: VaultItemDatabaseProtocol,
    item: Phone,
    pasteboardService: PasteboardServiceProtocol,
    completion: @escaping (VaultItem, String) -> Void
  ) {
    self.init(
      service: .init(
        item: item, vaultItemDatabase: vaultItemDatabase, pasteboardService: pasteboardService),
      completion: completion)
  }

  init(
    service: DetailServiceContextMenuAutofill<Phone>,
    completion: @escaping (VaultItem, String) -> Void
  ) {
    self.service = service
    self.completion = completion
  }
}

extension ContextMenuPhoneDetailViewModel {
  static func mock() -> ContextMenuPhoneDetailViewModel {
    ContextMenuPhoneDetailViewModel(
      vaultItemDatabase: .mock(),
      item: PersonalDataMock.Phones.personal,
      pasteboardService: .mock(),
      completion: { _, _ in }
    )
  }
}
