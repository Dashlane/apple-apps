import Combine
import CorePersonalData
import CoreSettings
import CoreTypes
import Foundation
import SwiftUI
import UserTrackingFoundation
import VaultKit

class ContextMenuCreditCardDetailViewModel: ContextMenuDetailViewModelProtocol,
  SessionServicesInjecting
{

  let service: DetailServiceContextMenuAutofill<CreditCard>
  let completion: (VaultItem, String) -> Void

  convenience init(
    vaultItemDatabase: VaultItemDatabaseProtocol,
    item: CreditCard,
    pasteboardService: PasteboardServiceProtocol,
    completion: @escaping (VaultItem, String) -> Void
  ) {
    self.init(
      service: .init(
        item: item, vaultItemDatabase: vaultItemDatabase, pasteboardService: pasteboardService),
      completion: completion)
  }

  init(
    service: DetailServiceContextMenuAutofill<CreditCard>,
    completion: @escaping (VaultItem, String) -> Void
  ) {
    self.service = service
    self.completion = completion
  }
}

extension ContextMenuCreditCardDetailViewModel {
  static func mock() -> ContextMenuCreditCardDetailViewModel {
    ContextMenuCreditCardDetailViewModel(
      vaultItemDatabase: .mock(),
      item: PersonalDataMock.CreditCards.personal,
      pasteboardService: .mock(),
      completion: { _, _ in }
    )
  }
}
