import Combine
import CorePersonalData
import CoreSettings
import CoreTypes
import Foundation
import SwiftUI
import UserTrackingFoundation
import VaultKit

class ContextMenuIDCardDetailViewModel: ContextMenuDetailViewModelProtocol, SessionServicesInjecting
{

  let service: DetailServiceContextMenuAutofill<IDCard>
  let completion: (VaultItem, String) -> Void

  var displayFullName: String {
    self.item.linkedIdentity?.displayNameWithoutMiddleName ?? item.fullName
  }

  convenience init(
    vaultItemDatabase: VaultItemDatabaseProtocol,
    item: IDCard,
    pasteboardService: PasteboardServiceProtocol,
    completion: @escaping (VaultItem, String) -> Void
  ) {
    self.init(
      service: .init(
        item: item, vaultItemDatabase: vaultItemDatabase, pasteboardService: pasteboardService),
      completion: completion)
  }

  init(
    service: DetailServiceContextMenuAutofill<IDCard>,
    completion: @escaping (VaultItem, String) -> Void
  ) {
    self.service = service
    self.completion = completion
  }

}

extension ContextMenuIDCardDetailViewModel {
  static func mock() -> ContextMenuIDCardDetailViewModel {
    ContextMenuIDCardDetailViewModel(
      vaultItemDatabase: .mock(),
      item: PersonalDataMock.IDCards.personal,
      pasteboardService: .mock(),
      completion: { _, _ in }
    )
  }
}
