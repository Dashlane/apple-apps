import Combine
import CoreActivityLogs
import CoreLocalization
import CorePersonalData
import CorePremium
import CoreSettings
import CoreUserTracking
import DashTypes
import DocumentServices
import Foundation
import UIComponents
import VaultKit

class EmailDetailViewModel: DetailViewModelProtocol, SessionServicesInjecting,
  MockVaultConnectedInjecting
{
  let service: DetailService<CorePersonalData.Email>

  private var cancellables: Set<AnyCancellable> = []
  private var vaultItemsStore: VaultItemsStore {
    service.vaultItemsStore
  }

  @Published
  var hasTypeField: Bool = false

  convenience init(
    item: CorePersonalData.Email,
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

    hasTypeField = userSpacesService.configuration.supportEmailTypeField
    userSpacesService.$configuration.map(\.supportEmailTypeField).assign(to: &$hasTypeField)
  }

  init(
    service: DetailService<CorePersonalData.Email>
  ) {
    self.service = service

    registerServiceChanges()
    setupName()
  }

  private func registerServiceChanges() {
    service
      .objectWillChange
      .sink { [weak self] in
        self?.objectWillChange.send()
      }
      .store(in: &cancellables)
  }

  private func setupName() {
    if mode.isAdding {
      let count = vaultItemsStore.emails.count + 1
      item.name = "\(CoreLocalization.L10n.Core.kwEmailIOS) \(count)"
    }
  }
}

extension UserSpacesService.SpacesConfiguration {
  var supportEmailTypeField: Bool {
    return currentTeam == nil
  }
}
