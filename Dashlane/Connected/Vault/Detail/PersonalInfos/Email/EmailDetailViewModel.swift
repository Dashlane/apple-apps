import Combine
import CoreActivityLogs
import CoreFeature
import CoreLocalization
import CorePersonalData
import CorePremium
import CoreSession
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
      .receive(on: DispatchQueue.main)
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
