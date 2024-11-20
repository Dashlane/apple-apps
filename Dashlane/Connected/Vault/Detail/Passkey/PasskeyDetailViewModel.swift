import Combine
import CoreActivityLogs
import CoreFeature
import CorePersonalData
import CorePremium
import CoreSession
import CoreSettings
import CoreUserTracking
import DashTypes
import DocumentServices
import Foundation
import SwiftUI
import UIComponents
import VaultKit

@MainActor
class PasskeyDetailViewModel: DetailViewModelProtocol, SessionServicesInjecting,
  MockVaultConnectedInjecting
{

  let service: DetailService<CorePersonalData.Passkey>

  let isUsernameAnEmail: Bool

  private var cancellables: Set<AnyCancellable> = []

  enum Error: String, Swift.Error {
    case cannotChangePasskeyData
  }

  convenience init(
    item: CorePersonalData.Passkey,
    mode: DetailMode = .viewing,
    session: Session,
    vaultItemDatabase: VaultItemDatabaseProtocol,
    vaultItemsStore: VaultItemsStore,
    vaultCollectionDatabase: VaultCollectionDatabaseProtocol,
    vaultCollectionsStore: VaultCollectionsStore,
    vaultStateService: VaultStateServiceProtocol,
    sharingService: SharedVaultHandling,
    userSpacesService: UserSpacesService,
    deepLinkService: VaultKit.DeepLinkingServiceProtocol,
    activityReporter: ActivityReporterProtocol,
    activityLogsService: ActivityLogsServiceProtocol,
    iconViewModelProvider: @escaping (VaultItem) -> VaultItemIconViewModel,
    logger: Logger,
    accessControl: AccessControlHandler,
    userSettings: UserSettings,
    pasteboardService: PasteboardServiceProtocol,
    documentStorageService: DocumentStorageService,
    attachmentSectionFactory: AttachmentsSectionViewModel.Factory,
    dismiss: (() -> Void)? = nil
  ) {
    self.init(
      service: .init(
        item: item,
        canLock: session.authenticationMethod.supportsLock,
        mode: mode,
        vaultItemDatabase: vaultItemDatabase,
        vaultItemsStore: vaultItemsStore,
        vaultStateService: vaultStateService,
        vaultCollectionDatabase: vaultCollectionDatabase,
        vaultCollectionsStore: vaultCollectionsStore,
        sharingService: sharingService,
        userSpacesService: userSpacesService,
        documentStorageService: documentStorageService,
        deepLinkService: deepLinkService,
        activityReporter: activityReporter,
        activityLogsService: activityLogsService,
        iconViewModelProvider: iconViewModelProvider,
        attachmentSectionFactory: attachmentSectionFactory,
        logger: logger,
        userSettings: userSettings,
        pasteboardService: pasteboardService
      )
    )
  }

  init(
    service: DetailService<CorePersonalData.Passkey>
  ) {
    self.service = service
    self.isUsernameAnEmail = Email(service.item.userDisplayName).isValid
    registerServiceChanges()
  }

  private func registerServiceChanges() {
    service
      .objectWillChange
      .receive(on: DispatchQueue.main)
      .sink { [weak self] in
        self?.objectWillChange.send()
      }
      .store(in: &cancellables)
  }

  func prepareForSaving() throws {
    guard item.valideChange(for: originalItem) else {
      throw Error.cannotChangePasskeyData
    }
    try service.prepareForSaving()
  }

  func delete() async {
    await service.delete()
  }

}

extension Passkey {
  fileprivate func valideChange(for originalItem: Passkey) -> Bool {
    originalItem.privateKey == privateKey && originalItem.credentialId == credentialId
      && originalItem.userHandle == userHandle && originalItem.userDisplayName == userDisplayName
      && originalItem.keyAlgorithm == keyAlgorithm && originalItem.relyingPartyId == relyingPartyId
      && originalItem.relyingPartyName == relyingPartyName
  }
}
