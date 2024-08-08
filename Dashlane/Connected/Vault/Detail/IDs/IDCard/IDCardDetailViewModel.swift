import Combine
import CoreActivityLogs
import CorePasswords
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

final class IDCardDetailViewModel: DetailViewModelProtocol, SessionServicesInjecting,
  MockVaultConnectedInjecting
{
  var identities: [Identity] = []

  var displayFullName: String {
    self.item.linkedIdentity?.displayNameWithoutMiddleName ?? item.fullName
  }

  let service: DetailService<IDCard>

  private var cancellables: Set<AnyCancellable> = []
  private var vaultItemsStore: VaultItemsStore {
    service.vaultItemsStore
  }

  convenience init(
    item: IDCard,
    mode: DetailMode = .viewing,
    vaultItemDatabase: VaultItemDatabaseProtocol,
    vaultItemsStore: VaultItemsStore,
    vaultCollectionDatabase: VaultCollectionDatabaseProtocol,
    vaultCollectionsStore: VaultCollectionsStore,
    sharingService: SharedVaultHandling,
    userSpacesService: UserSpacesService,
    documentStorageService: DocumentStorageService,
    deepLinkService: VaultKit.DeepLinkingServiceProtocol,
    activityReporter: ActivityReporterProtocol,
    activityLogsService: ActivityLogsServiceProtocol,
    iconViewModelProvider: @escaping (VaultItem) -> VaultItemIconViewModel,
    logger: Logger,
    accessControl: AccessControlProtocol,
    userSettings: UserSettings,
    pasteboardService: PasteboardServiceProtocol,
    attachmentSectionFactory: AttachmentsSectionViewModel.Factory
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
    service: DetailService<IDCard>
  ) {
    self.service = service

    registerServiceChanges()
    setupIdentities()
  }

  private func registerServiceChanges() {
    service
      .objectWillChange
      .sink { [weak self] in
        self?.objectWillChange.send()
      }
      .store(in: &cancellables)
  }

  private func setupIdentities() {
    vaultItemsStore.$identities
      .assign(to: \.identities, on: self)
      .store(in: &cancellables)
    if mode.isAdding {
      item.linkedIdentity = identities.first
    }
    identities = vaultItemsStore.identities
  }
}
