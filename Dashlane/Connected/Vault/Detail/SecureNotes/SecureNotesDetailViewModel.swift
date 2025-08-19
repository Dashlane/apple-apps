import Combine
import CoreFeature
import CorePersonalData
import CorePremium
import CoreSession
import CoreSettings
import CoreTeamAuditLogs
import CoreTypes
import DocumentServices
import Foundation
import LogFoundation
import UIComponents
import UIKit
import UserTrackingFoundation
import VaultKit

@MainActor
final class SecureNotesDetailViewModel: DetailViewModelProtocol, SessionServicesInjecting,
  MockVaultConnectedInjecting
{
  var selectedColor: SecureNoteColor {
    get {
      return item.color
    }
    set {
      item.color = newValue
    }
  }

  var shouldShowLockButton: Bool {
    session.configuration.info.accountType != .sso
  }

  let service: DetailService<SecureNote>

  let attachmentsListViewModelFactory: AttachmentsListViewModel.Factory
  let shareButtonViewModelFactory: ShareButtonViewModel.Factory
  let sharingDetailSectionModelFactory: SharingDetailSectionModel.Factory
  let sharingMembersDetailLinkModelFactory: SharingMembersDetailLinkModel.Factory

  let session: Session

  private var userSpacesService: UserSpacesService {
    service.userSpacesService
  }

  private var cancellables: Set<AnyCancellable> = []

  convenience init(
    item: SecureNote,
    session: Session,
    mode: DetailMode = .viewing,
    vaultItemDatabase: VaultItemDatabaseProtocol,
    vaultItemsStore: VaultItemsStore,
    vaultCollectionDatabase: VaultCollectionDatabaseProtocol,
    vaultCollectionsStore: VaultCollectionsStore,
    vaultStateService: VaultStateServiceProtocol,
    sharingService: SharedVaultHandling,
    userSpacesService: UserSpacesService,
    deepLinkService: VaultKit.DeepLinkingServiceProtocol,
    activityReporter: ActivityReporterProtocol,
    teamAuditLogsService: TeamAuditLogsServiceProtocol,
    pasteboardService: PasteboardServiceProtocol,
    iconViewModelProvider: @escaping (VaultItem) -> VaultItemIconViewModel,
    sharingDetailSectionModelFactory: SharingDetailSectionModel.Factory,
    sharingMembersDetailLinkModelFactory: SharingMembersDetailLinkModel.Factory,
    shareButtonViewModelFactory: ShareButtonViewModel.Factory,
    attachmentsListViewModelFactory: AttachmentsListViewModel.Factory,
    attachmentSectionFactory: AttachmentsSectionViewModel.Factory,
    logger: Logger,
    documentStorageService: DocumentStorageService,
    userSettings: UserSettings
  ) {
    self.init(
      session: session,
      service: .init(
        item: item,
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
        teamAuditLogsService: teamAuditLogsService,
        iconViewModelProvider: iconViewModelProvider,
        attachmentSectionFactory: attachmentSectionFactory,
        logger: logger,
        userSettings: userSettings,
        pasteboardService: pasteboardService
      ),
      sharingDetailSectionModelFactory: sharingDetailSectionModelFactory,
      sharingMembersDetailLinkModelFactory: sharingMembersDetailLinkModelFactory,
      shareButtonViewModelFactory: shareButtonViewModelFactory,
      attachmentsListViewModelFactory: attachmentsListViewModelFactory
    )
  }

  init(
    session: Session,
    service: DetailService<SecureNote>,
    sharingDetailSectionModelFactory: SharingDetailSectionModel.Factory,
    sharingMembersDetailLinkModelFactory: SharingMembersDetailLinkModel.Factory,
    shareButtonViewModelFactory: ShareButtonViewModel.Factory,
    attachmentsListViewModelFactory: AttachmentsListViewModel.Factory
  ) {
    self.session = session
    self.service = service
    self.sharingDetailSectionModelFactory = sharingDetailSectionModelFactory
    self.sharingMembersDetailLinkModelFactory = sharingMembersDetailLinkModelFactory
    self.shareButtonViewModelFactory = shareButtonViewModelFactory
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
    Task {
      await save()
    }
  }
}
