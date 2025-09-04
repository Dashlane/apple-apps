import Combine
import CorePersonalData
import CoreSettings
import CoreTypes
import Foundation
import SwiftUI
import TOTPGenerator
import UserTrackingFoundation
import VaultKit

class CredentialMainSectionModel: DetailViewModelProtocol, SessionServicesInjecting,
  MockVaultConnectedInjecting
{

  @Binding
  var isAutoFillDemoModalShown: Bool

  @Binding
  var isAdd2FAFlowPresented: Bool

  var emailsSuggestions: [String] {
    vaultItemsStore.emails.map(\.value).sorted()
  }

  let passwordAccessorySectionModelFactory: PasswordAccessorySectionModel.Factory

  let service: DetailService<Credential>

  private var sharingService: SharedVaultHandling {
    service.sharingService
  }

  private var vaultItemsStore: VaultItemsStore {
    service.vaultItemsStore
  }

  init(
    service: DetailService<Credential>,
    isAutoFillDemoModalShown: Binding<Bool>,
    isAdd2FAFlowPresented: Binding<Bool>,
    passwordAccessorySectionModelFactory: PasswordAccessorySectionModel.Factory
  ) {
    self.service = service
    self._isAutoFillDemoModalShown = isAutoFillDemoModalShown
    self._isAdd2FAFlowPresented = isAdd2FAFlowPresented
    self.passwordAccessorySectionModelFactory = passwordAccessorySectionModelFactory
  }

}

extension CredentialMainSectionModel {
  static func mock(
    service: DetailService<Credential>,
    isAutoFillDemoModalShown: Binding<Bool>,
    isAdd2FAFlowPresented: Binding<Bool>
  ) -> CredentialMainSectionModel {
    CredentialMainSectionModel(
      service: service,
      isAutoFillDemoModalShown: isAutoFillDemoModalShown,
      isAdd2FAFlowPresented: isAdd2FAFlowPresented,
      passwordAccessorySectionModelFactory: .init { .mock(service: $0) }
    )
  }
}
