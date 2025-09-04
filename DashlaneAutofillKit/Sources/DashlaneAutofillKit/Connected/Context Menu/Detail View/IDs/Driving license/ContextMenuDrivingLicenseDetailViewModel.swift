import Combine
import CorePersonalData
import CoreSettings
import CoreTypes
import Foundation
import SwiftUI
import UserTrackingFoundation
import VaultKit

class ContextMenuDrivingLicenseDetailViewModel: ContextMenuDetailViewModelProtocol,
  SessionServicesInjecting
{

  let service: DetailServiceContextMenuAutofill<DrivingLicence>
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
    item: DrivingLicence,
    pasteboardService: PasteboardServiceProtocol,
    completion: @escaping (VaultItem, String) -> Void
  ) {
    self.init(
      service: .init(
        item: item, vaultItemDatabase: vaultItemDatabase, pasteboardService: pasteboardService),
      completion: completion)
  }

  init(
    service: DetailServiceContextMenuAutofill<DrivingLicence>,
    completion: @escaping (VaultItem, String) -> Void
  ) {
    self.service = service
    self.completion = completion
  }

}

extension ContextMenuDrivingLicenseDetailViewModel {
  static func mock() -> ContextMenuDrivingLicenseDetailViewModel {
    ContextMenuDrivingLicenseDetailViewModel(
      vaultItemDatabase: .mock(),
      item: PersonalDataMock.DrivingLicences.personal,
      pasteboardService: .mock(), completion: { _, _ in }
    )
  }
}
