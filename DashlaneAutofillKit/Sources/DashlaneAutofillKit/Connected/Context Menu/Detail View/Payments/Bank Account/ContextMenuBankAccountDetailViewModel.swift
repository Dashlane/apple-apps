import Combine
import CorePersonalData
import CoreSettings
import CoreTypes
import Foundation
import SwiftUI
import UserTrackingFoundation
import VaultKit

class ContextMenuBankAccountDetailViewModel: ContextMenuDetailViewModelProtocol,
  SessionServicesInjecting
{

  let service: DetailServiceContextMenuAutofill<BankAccount>
  let regionInformationService: RegionInformationService
  let completion: (VaultItem, String) -> Void

  var banks: [BankCodeNamePair] {
    regionInformationService.bankInfo.banks(forCountryCode: self.item.country?.code)
  }

  var selectedBank: BankCodeNamePair? {
    guard let bank = item.bank else {
      return banks.first
    }
    return bank
  }

  var selectedCountry: CountryCodeNamePair? {
    guard let country = item.country else {
      return CountryCodeNamePair.defaultCountry
    }
    return country
  }

  convenience init(
    vaultItemDatabase: VaultItemDatabaseProtocol,
    item: BankAccount,
    pasteboardService: PasteboardServiceProtocol,
    regionInformationService: RegionInformationService,
    completion: @escaping (VaultItem, String) -> Void
  ) {
    self.init(
      service: .init(
        item: item, vaultItemDatabase: vaultItemDatabase, pasteboardService: pasteboardService),
      regionInformationService: regionInformationService,
      completion: completion)
  }

  init(
    service: DetailServiceContextMenuAutofill<BankAccount>,
    regionInformationService: RegionInformationService,
    completion: @escaping (VaultItem, String) -> Void
  ) {
    self.service = service
    self.regionInformationService = regionInformationService
    self.completion = completion
  }

}

extension ContextMenuBankAccountDetailViewModel {
  static func mock() -> ContextMenuBankAccountDetailViewModel {
    ContextMenuBankAccountDetailViewModel(
      vaultItemDatabase: .mock(),
      item: PersonalDataMock.BankAccounts.personal,
      pasteboardService: .mock(),
      regionInformationService: try! RegionInformationService(),
      completion: { _, _ in }
    )
  }
}
