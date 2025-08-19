import Combine
import CorePersonalData
import CoreSettings
import CoreTypes
import Foundation
import SwiftUI
import UserTrackingFoundation
import VaultKit

class ContextMenuEmailDetailViewModel: ContextMenuDetailViewModelProtocol, SessionServicesInjecting
{

  let service: DetailServiceContextMenuAutofill<CorePersonalData.Email>
  let completion: (VaultItem, String) -> Void

  convenience init(
    vaultItemDatabase: VaultItemDatabaseProtocol,
    item: CorePersonalData.Email,
    pasteboardService: PasteboardServiceProtocol,
    completion: @escaping (VaultItem, String) -> Void
  ) {
    self.init(
      service: .init(
        item: item, vaultItemDatabase: vaultItemDatabase, pasteboardService: pasteboardService),
      completion: completion)
  }

  init(
    service: DetailServiceContextMenuAutofill<CorePersonalData.Email>,
    completion: @escaping (VaultItem, String) -> Void
  ) {
    self.service = service
    self.completion = completion
  }
}

extension ContextMenuEmailDetailViewModel {
  static func mock() -> ContextMenuEmailDetailViewModel {
    ContextMenuEmailDetailViewModel(
      vaultItemDatabase: .mock(),
      item: PersonalDataMock.Emails.work,
      pasteboardService: .mock(),
      completion: { _, _ in }
    )
  }
}
