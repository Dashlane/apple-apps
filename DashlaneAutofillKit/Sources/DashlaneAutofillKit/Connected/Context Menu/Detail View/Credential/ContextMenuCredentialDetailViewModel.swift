import Combine
import CorePersonalData
import CoreSettings
import CoreTypes
import Foundation
import SwiftUI
import TOTPGenerator
import UserTrackingFoundation
import VaultKit

class ContextMenuCredentialDetailViewModel: ContextMenuDetailViewModelProtocol,
  SessionServicesInjecting
{

  let service: DetailServiceContextMenuAutofill<Credential>
  let completion: (VaultItem, String) -> Void

  var totpCode: String? {
    guard let otpURL = item.otpURL else {
      return nil
    }
    return try? OTPConfiguration(otpURL: otpURL).generate()
  }

  convenience init(
    vaultItemDatabase: VaultItemDatabaseProtocol,
    item: Credential,
    pasteboardService: PasteboardServiceProtocol,
    completion: @escaping (VaultItem, String) -> Void
  ) {
    self.init(
      service: .init(
        item: item, vaultItemDatabase: vaultItemDatabase, pasteboardService: pasteboardService),
      completion: completion)
  }

  init(
    service: DetailServiceContextMenuAutofill<Credential>,
    completion: @escaping (VaultItem, String) -> Void
  ) {
    self.service = service
    self.completion = completion
  }
}

extension ContextMenuCredentialDetailViewModel {
  static func mock() -> ContextMenuCredentialDetailViewModel {
    ContextMenuCredentialDetailViewModel(
      vaultItemDatabase: .mock(),
      item: PersonalDataMock.Credentials.franceTV,
      pasteboardService: .mock(),
      completion: { _, _ in }
    )
  }
}
