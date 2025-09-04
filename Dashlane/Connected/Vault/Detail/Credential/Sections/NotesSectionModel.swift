import Combine
import CorePersonalData
import CoreSettings
import CoreTypes
import Foundation
import SwiftUI
import UserTrackingFoundation
import VaultKit

class NotesSectionModel: DetailViewModelProtocol, SessionServicesInjecting,
  MockVaultConnectedInjecting
{

  let service: DetailService<Credential>

  private var sharingService: SharedVaultHandling {
    service.sharingService
  }

  init(
    service: DetailService<Credential>
  ) {
    self.service = service
  }
}

extension NotesSectionModel {
  static func mock(service: DetailService<Credential>) -> NotesSectionModel {
    NotesSectionModel(service: service)
  }
}
