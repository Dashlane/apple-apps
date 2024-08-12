import Combine
import CoreActivityLogs
import CorePersonalData
import CorePremium
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
    vaultItemDatabase: VaultItemDatabaseProtocol,
    vaultItemsStore: VaultItemsStore,
    vaultCollectionDatabase: VaultCollectionDatabaseProtocol,
    vaultCollectionsStore: VaultCollectionsStore,
    sharingService: SharedVaultHandling,
    userSpacesService: UserSpacesService,
    deepLinkService: VaultKit.DeepLinkingServiceProtocol,
    activityReporter: ActivityReporterProtocol,
    activityLogsService: ActivityLogsServiceProtocol,
    iconViewModelProvider: @escaping (VaultItem) -> VaultItemIconViewModel,
    logger: Logger,
    accessControl: AccessControlProtocol,
    userSettings: UserSettings,
    pasteboardService: PasteboardServiceProtocol,
    documentStorageService: DocumentStorageService,
    attachmentSectionFactory: AttachmentsSectionViewModel.Factory,
    dismiss: (() -> Void)? = nil
  ) {
    self.init(
      service: .init(
        item: item,
        mode: mode,
        vaultItemDatabase: vaultItemDatabase,
        vaultItemsStore: vaultItemsStore,
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
        accessControl: accessControl,
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
