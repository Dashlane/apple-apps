import Combine
import CorePersonalData
import CoreSettings
import CoreTypes
import Foundation
import SwiftUI
import UserTrackingFoundation
import VaultKit

class ContextMenuCompanyDetailViewModel: ContextMenuDetailViewModelProtocol,
  SessionServicesInjecting
{

  let service: DetailServiceContextMenuAutofill<Company>
  let completion: (VaultItem, String) -> Void

  convenience init(
    vaultItemDatabase: VaultItemDatabaseProtocol,
    item: Company,
    pasteboardService: PasteboardServiceProtocol,
    completion: @escaping (VaultItem, String) -> Void
  ) {
    self.init(
      service: .init(
        item: item, vaultItemDatabase: vaultItemDatabase, pasteboardService: pasteboardService),
      completion: completion)
  }

  init(
    service: DetailServiceContextMenuAutofill<Company>,
    completion: @escaping (VaultItem, String) -> Void
  ) {
    self.service = service
    self.completion = completion
  }
}

extension ContextMenuCompanyDetailViewModel {
  static func mock() -> ContextMenuCompanyDetailViewModel {
    ContextMenuCompanyDetailViewModel(
      vaultItemDatabase: .mock(),
      item: PersonalDataMock.Companies.dashlane,
      pasteboardService: .mock(),
      completion: { _, _ in }
    )
  }
}
