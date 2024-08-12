import CorePersonalData
import CorePremium
import CoreSession
import CoreSharing
import Foundation
import SwiftUI
import VaultKit

class SecureNotesDetailToolbarModel: DetailViewModelProtocol, SessionServicesInjecting,
  MockVaultConnectedInjecting
{

  var shouldShowLockButton: Bool {
    session.configuration.info.accountType != .sso
  }

  var selectedUserSpace: UserSpace {
    userSpacesService.configuration.editingUserSpace(for: item)
  }

  var availableUserSpaces: [UserSpace] {
    userSpacesService.configuration.availableSpaces.filter { $0 != .both }
  }

  let shareButtonViewModelFactory: ShareButtonViewModel.Factory
  let session: Session
  let service: DetailService<SecureNote>

  private var userSpacesService: UserSpacesService {
    service.userSpacesService
  }

  init(
    service: DetailService<SecureNote>,
    session: Session,
    shareButtonViewModelFactory: ShareButtonViewModel.Factory
  ) {
    self.session = session
    self.service = service
    self.shareButtonViewModelFactory = shareButtonViewModelFactory
  }
}

extension SecureNotesDetailToolbarModel {
  static func mock(service: DetailService<SecureNote>) -> SecureNotesDetailToolbarModel {
    SecureNotesDetailToolbarModel(
      service: service,
      session: .mock,
      shareButtonViewModelFactory: .init { .mock(items: $0, userGroupIds: $1, userEmails: $2) }
    )
  }
}
