import Combine
import CoreActivityLogs
import CoreFeature
import CorePasswords
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

class SocialSecurityDetailViewModel: DetailViewModelProtocol, SessionServicesInjecting,
  MockVaultConnectedInjecting
{

  var identities: [Identity] = []

  var displayFullName: String {
    linkedIdentityFullName ?? item.fullname
  }

  let service: DetailService<SocialSecurityInformation>

  private var linkedIdentityFullName: String? {
    let names = [item.linkedIdentity?.firstName, item.linkedIdentity?.lastName].compactMap { $0 }
    return names.isEmpty ? nil : names.joined(separator: " ")
  }

  private var cancellables: Set<AnyCancellable> = []
  private var vaultItemsStore: VaultItemsStore {
    service.vaultItemsStore
  }

  convenience init(
    item: SocialSecurityInformation,
    mode: DetailMode = .viewing,
    session: Session,
    vaultItemDatabase: VaultItemDatabaseProtocol,
    vaultItemsStore: VaultItemsStore,
    vaultCollectionDatabase: VaultCollectionDatabaseProtocol,
    vaultCollectionsStore: VaultCollectionsStore,
    vaultStateService: VaultStateServiceProtocol,
    sharingService: SharedVaultHandling,
    userSpacesService: UserSpacesService,
    documentStorageService: DocumentStorageService,
    deepLinkService: VaultKit.DeepLinkingServiceProtocol,
    activityReporter: ActivityReporterProtocol,
    activityLogsService: ActivityLogsServiceProtocol,
    iconViewModelProvider: @escaping (VaultItem) -> VaultItemIconViewModel,
    logger: Logger,
    userSettings: UserSettings,
    pasteboardService: PasteboardServiceProtocol,
    attachmentSectionFactory: AttachmentsSectionViewModel.Factory
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
    service: DetailService<SocialSecurityInformation>
  ) {
    self.service = service

    registerServiceChanges()
    setupIdentities()
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
