import Combine
import CoreActivityLogs
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
import UIKit
import VaultKit

public final class SecretDetailViewModel: DetailViewModelProtocol, SessionServicesInjecting,
  MockVaultConnectedInjecting
{

  public let service: DetailService<Secret>

  let attachmentsListViewModelFactory: AttachmentsListViewModel.Factory
  let sharingDetailSectionModelFactory: SharingDetailSectionModel.Factory

  private var userSpacesService: UserSpacesService {
    service.userSpacesService
  }

  private var cancellables: Set<AnyCancellable> = []

  convenience init(
    item: Secret,
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
    documentStorageService: DocumentStorageService,
    sharingDetailSectionModelFactory: SharingDetailSectionModel.Factory,
    pasteboardService: PasteboardServiceProtocol,
    iconViewModelProvider: @escaping (VaultItem) -> VaultItemIconViewModel,
    attachmentsListViewModelFactory: AttachmentsListViewModel.Factory,
    attachmentSectionFactory: AttachmentsSectionViewModel.Factory,
    logger: Logger,
    accessControl: AccessControlProtocol,
    userSettings: UserSettings
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
      ),
      attachmentsListViewModelFactory: attachmentsListViewModelFactory,
      sharingDetailSectionModelFactory: sharingDetailSectionModelFactory
    )
  }

  init(
    service: DetailService<Secret>,
    attachmentsListViewModelFactory: AttachmentsListViewModel.Factory,
    sharingDetailSectionModelFactory: SharingDetailSectionModel.Factory
  ) {
    self.service = service
    self.sharingDetailSectionModelFactory = sharingDetailSectionModelFactory
    self.attachmentsListViewModelFactory = attachmentsListViewModelFactory
    registerServiceChanges()
    setupAutoSave()
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
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

  private func setupAutoSave() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(autoSave),
      name: UIApplication.applicationWillResignActiveNotification,
      object: nil
    )
  }

  @objc private func autoSave() {
    guard mode.isAdding || mode.isEditing, canSave else { return }
    Task { @MainActor in
      await save()
    }
  }

  public func makeSecretMainSectionViewModel() -> SecretMainSectionModel {
    .init(service: service)
  }
}
