import Combine
import CorePersonalData
import CoreSettings
import CoreTypes
import Foundation
import SwiftUI
import UserTrackingFoundation
import VaultKit

class ContextMenuFiscalInformationDetailViewModel: ContextMenuDetailViewModelProtocol,
  SessionServicesInjecting
{

  let service: DetailServiceContextMenuAutofill<FiscalInformation>
  let completion: (VaultItem, String) -> Void

  var selectedCountry: CountryCodeNamePair? {
    guard let country = item.country else {
      return CountryCodeNamePair.defaultCountry
    }
    return country
  }

  convenience init(
    vaultItemDatabase: VaultItemDatabaseProtocol,
    item: FiscalInformation,
    pasteboardService: PasteboardServiceProtocol,
    completion: @escaping (VaultItem, String) -> Void
  ) {
    self.init(
      service: .init(
        item: item, vaultItemDatabase: vaultItemDatabase, pasteboardService: pasteboardService),
      completion: completion)
  }

  init(
    service: DetailServiceContextMenuAutofill<FiscalInformation>,
    completion: @escaping (VaultItem, String) -> Void
  ) {
    self.service = service
    self.completion = completion
  }

}

extension ContextMenuFiscalInformationDetailViewModel {
  static func mock() -> ContextMenuFiscalInformationDetailViewModel {
    ContextMenuFiscalInformationDetailViewModel(
      vaultItemDatabase: .mock(),
      item: PersonalDataMock.FiscalInformations.personal,
      pasteboardService: .mock(),
      completion: { _, _ in }
    )
  }
}
