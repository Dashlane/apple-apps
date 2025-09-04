import Combine
import CorePersonalData
import CoreSettings
import CoreTypes
import Foundation
import SwiftUI
import UserTrackingFoundation
import VaultKit

class ContextMenuWebsiteDetailViewModel: ContextMenuDetailViewModelProtocol,
  SessionServicesInjecting
{

  let service: DetailServiceContextMenuAutofill<PersonalWebsite>
  let completion: (VaultItem, String) -> Void

  convenience init(
    vaultItemDatabase: VaultItemDatabaseProtocol,
    item: PersonalWebsite,
    pasteboardService: PasteboardServiceProtocol,
    completion: @escaping (VaultItem, String) -> Void
  ) {
    self.init(
      service: .init(
        item: item, vaultItemDatabase: vaultItemDatabase, pasteboardService: pasteboardService),
      completion: completion)
  }

  init(
    service: DetailServiceContextMenuAutofill<PersonalWebsite>,
    completion: @escaping (VaultItem, String) -> Void
  ) {
    self.service = service
    self.completion = completion
  }
}

extension ContextMenuWebsiteDetailViewModel {
  static func mock() -> ContextMenuWebsiteDetailViewModel {
    ContextMenuWebsiteDetailViewModel(
      vaultItemDatabase: .mock(),
      item: PersonalDataMock.PersonalWebsites.blog,
      pasteboardService: .mock(),
      completion: { _, _ in }
    )
  }
}
