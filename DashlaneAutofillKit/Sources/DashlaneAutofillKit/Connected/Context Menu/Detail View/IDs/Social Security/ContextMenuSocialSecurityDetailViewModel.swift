import Combine
import CorePersonalData
import CoreSettings
import CoreTypes
import Foundation
import SwiftUI
import UserTrackingFoundation
import VaultKit

class ContextMenuSocialSecurityDetailViewModel: ContextMenuDetailViewModelProtocol,
  SessionServicesInjecting
{

  let service: DetailServiceContextMenuAutofill<SocialSecurityInformation>
  let completion: (VaultItem, String) -> Void

  var displayFullName: String {
    linkedIdentityFullName ?? item.fullname
  }

  private var linkedIdentityFullName: String? {
    let names = [item.linkedIdentity?.firstName, item.linkedIdentity?.lastName].compactMap { $0 }
    return names.isEmpty ? nil : names.joined(separator: " ")
  }

  convenience init(
    vaultItemDatabase: VaultItemDatabaseProtocol,
    item: SocialSecurityInformation,
    pasteboardService: PasteboardServiceProtocol,
    completion: @escaping (VaultItem, String) -> Void
  ) {
    self.init(
      service: .init(
        item: item, vaultItemDatabase: vaultItemDatabase, pasteboardService: pasteboardService),
      completion: completion)
  }

  init(
    service: DetailServiceContextMenuAutofill<SocialSecurityInformation>,
    completion: @escaping (VaultItem, String) -> Void
  ) {
    self.service = service
    self.completion = completion
  }

}

extension ContextMenuSocialSecurityDetailViewModel {
  static func mock() -> ContextMenuSocialSecurityDetailViewModel {
    ContextMenuSocialSecurityDetailViewModel(
      vaultItemDatabase: .mock(),
      item: PersonalDataMock.SocialSecurityInformations.gb,
      pasteboardService: .mock(),
      completion: { _, _ in }
    )
  }
}
