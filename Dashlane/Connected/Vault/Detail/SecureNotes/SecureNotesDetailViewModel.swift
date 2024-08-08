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
import UIComponents
import UIKit
import VaultKit

final class SecureNotesDetailViewModel: DetailViewModelProtocol, SessionServicesInjecting,
  MockVaultConnectedInjecting
{

  private var deleteAttachmentsSubscriber: AnyCancellable?

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
  let secureNotesDetailFieldsModelFactory: SecureNotesDetailFieldsModel.Factory
  let secureNotesDetailNavigationBarModelFactory: SecureNotesDetailNavigationBarModel.Factory
  let secureNotesDetailToolbarFactory: SecureNotesDetailToolbarModel.Factory
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
    sharingService: SharedVaultHandling,
    userSpacesService: UserSpacesService,
    deepLinkService: VaultKit.DeepLinkingServiceProtocol,
    activityReporter: ActivityReporterProtocol,
    activityLogsService: ActivityLogsServiceProtocol,
    pasteboardService: PasteboardServiceProtocol,
    iconViewModelProvider: @escaping (VaultItem) -> VaultItemIconViewModel,
    secureNotesDetailNavigationBarModelFactory: SecureNotesDetailNavigationBarModel.Factory,
    secureNotesDetailFieldsModelFactory: SecureNotesDetailFieldsModel.Factory,
    secureNotesDetailToolbarModelFactory: SecureNotesDetailToolbarModel.Factory,
    sharingDetailSectionModelFactory: SharingDetailSectionModel.Factory,
    sharingMembersDetailLinkModelFactory: SharingMembersDetailLinkModel.Factory,
    shareButtonViewModelFactory: ShareButtonViewModel.Factory,
    attachmentsListViewModelFactory: AttachmentsListViewModel.Factory,
    attachmentSectionFactory: AttachmentsSectionViewModel.Factory,
    logger: Logger,
    documentStorageService: DocumentStorageService,
    accessControl: AccessControlProtocol,
    userSettings: UserSettings
  ) {
    self.init(
      session: session,
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
      secureNotesDetailNavigationBarModelFactory: secureNotesDetailNavigationBarModelFactory,
      secureNotesDetailFieldsModelFactory: secureNotesDetailFieldsModelFactory,
      secureNotesDetailToolbarFactory: secureNotesDetailToolbarModelFactory,
      sharingDetailSectionModelFactory: sharingDetailSectionModelFactory,
      sharingMembersDetailLinkModelFactory: sharingMembersDetailLinkModelFactory,
      shareButtonViewModelFactory: shareButtonViewModelFactory,
      attachmentsListViewModelFactory: attachmentsListViewModelFactory
    )
  }

  init(
    session: Session,
    service: DetailService<SecureNote>,
    secureNotesDetailNavigationBarModelFactory: SecureNotesDetailNavigationBarModel.Factory,
    secureNotesDetailFieldsModelFactory: SecureNotesDetailFieldsModel.Factory,
    secureNotesDetailToolbarFactory: SecureNotesDetailToolbarModel.Factory,
    sharingDetailSectionModelFactory: SharingDetailSectionModel.Factory,
    sharingMembersDetailLinkModelFactory: SharingMembersDetailLinkModel.Factory,
    shareButtonViewModelFactory: ShareButtonViewModel.Factory,
    attachmentsListViewModelFactory: AttachmentsListViewModel.Factory
  ) {
    self.session = session
    self.service = service
    self.secureNotesDetailNavigationBarModelFactory = secureNotesDetailNavigationBarModelFactory
    self.secureNotesDetailFieldsModelFactory = secureNotesDetailFieldsModelFactory
    self.secureNotesDetailToolbarFactory = secureNotesDetailToolbarFactory
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

  func makeAttachmentsListViewModel() -> AttachmentsListViewModel? {
    let publisher = service.vaultItemDatabase
      .itemPublisher(for: item)
      .map { $0 as VaultItem }
      .eraseToAnyPublisher()
    return attachmentsListViewModelFactory.make(editingItem: item, itemPublisher: publisher)
  }
}
