import Combine
import CorePersonalData
import CoreSettings
import CoreTypes
import Foundation
import SwiftUI
import UserTrackingFoundation
import VaultKit

class ContextMenuPassportDetailViewModel: ContextMenuDetailViewModelProtocol,
  SessionServicesInjecting
{

  let service: DetailServiceContextMenuAutofill<Passport>
  let completion: (VaultItem, String) -> Void

  var displayFullName: String {
    linkedIdentityFullName ?? item.fullname
  }

  private var linkedIdentityFullName: String? {
    let names = [item.linkedIdentity?.firstName, item.linkedIdentity?.lastName].compactMap { $0 }
    return names.isEmpty ? nil : names.joined(separator: " ")
  }

  var selectedCountry: CountryCodeNamePair? {
    guard let country = item.country else {
      return CountryCodeNamePair.defaultCountry
    }
    return country
  }

  convenience init(
    vaultItemDatabase: VaultItemDatabaseProtocol,
    item: Passport,
    pasteboardService: PasteboardServiceProtocol,
    completion: @escaping (VaultItem, String) -> Void
  ) {
    self.init(
      service: .init(
        item: item, vaultItemDatabase: vaultItemDatabase, pasteboardService: pasteboardService),
      completion: completion)
  }

  init(
    service: DetailServiceContextMenuAutofill<Passport>,
    completion: @escaping (VaultItem, String) -> Void
  ) {
    self.service = service
    self.completion = completion
  }

}

extension ContextMenuPassportDetailViewModel {
  static func mock() -> ContextMenuPassportDetailViewModel {
    ContextMenuPassportDetailViewModel(
      vaultItemDatabase: .mock(),
      item: PersonalDataMock.Passports.personal,
      pasteboardService: .mock(),
      completion: { _, _ in }
    )
  }
}
