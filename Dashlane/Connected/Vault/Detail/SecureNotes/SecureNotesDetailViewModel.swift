import Foundation
import CorePersonalData
import SwiftUI
import CoreSession
import DashTypes
import Combine
import DashlaneAppKit
import DocumentServices
import CoreUserTracking
import CoreSettings
import VaultKit
import CoreFeature
import UIComponents

class SecureNotesDetailViewModel: DetailViewModelProtocol, SessionServicesInjecting, MockVaultConnectedInjecting {

    private var deleteAttachmentsSubscriber: AnyCancellable?

    var selectedColor: SecureNoteColor {
        get {
            return item.color
        } set {
            item.color = newValue
        }
    }

    var shouldShowLockButton: Bool {
        !teamSpacesService.isSSOUser
    }

    let service: DetailService<SecureNote>

    let secureNotesDetailNavigationBarModelFactory: SecureNotesDetailNavigationBarModel.Factory
    let secureNotesDetailFieldsModelFactory: SecureNotesDetailFieldsModel.Factory
    let secureNotesDetailToolbarFactory: SecureNotesDetailToolbarModel.Factory
    let sharingMembersDetailLinkModelFactory: SharingMembersDetailLinkModel.Factory
    let shareButtonViewModelFactory: ShareButtonViewModel.Factory
    let attachmentsListViewModelFactory: AttachmentsListViewModel.Factory

    private var teamSpacesService: VaultKit.TeamSpacesServiceProtocol {
        service.teamSpacesService
    }

    private var cancellables: Set<AnyCancellable> = []

    convenience init(
        item: SecureNote,
        session: Session,
        mode: DetailMode = .viewing,
        vaultItemsService: VaultItemsServiceProtocol,
        sharingService: SharedVaultHandling,
        teamSpacesService: TeamSpacesService,
        deepLinkService: VaultKit.DeepLinkingServiceProtocol,
        activityReporter: ActivityReporterProtocol,
        pasteboardService: PasteboardServiceProtocol,
        iconViewModelProvider: @escaping (VaultItem) -> VaultItemIconViewModel,
        secureNotesDetailNavigationBarModelFactory: SecureNotesDetailNavigationBarModel.Factory,
        secureNotesDetailFieldsModelFactory: SecureNotesDetailFieldsModel.Factory,
        secureNotesDetailToolbarModelFactory: SecureNotesDetailToolbarModel.Factory,
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
            service: .init(
                item: item,
                mode: mode,
                vaultItemsService: vaultItemsService,
                sharingService: sharingService,
                teamSpacesService: teamSpacesService,
                documentStorageService: documentStorageService,
                deepLinkService: deepLinkService,
                activityReporter: activityReporter,
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
            sharingMembersDetailLinkModelFactory: sharingMembersDetailLinkModelFactory,
            shareButtonViewModelFactory: shareButtonViewModelFactory,
            attachmentsListViewModelFactory: attachmentsListViewModelFactory
        )
    }

    init(
        service: DetailService<SecureNote>,
        secureNotesDetailNavigationBarModelFactory: SecureNotesDetailNavigationBarModel.Factory,
        secureNotesDetailFieldsModelFactory: SecureNotesDetailFieldsModel.Factory,
        secureNotesDetailToolbarFactory: SecureNotesDetailToolbarModel.Factory,
        sharingMembersDetailLinkModelFactory: SharingMembersDetailLinkModel.Factory,
        shareButtonViewModelFactory: ShareButtonViewModel.Factory,
        attachmentsListViewModelFactory: AttachmentsListViewModel.Factory
    ) {
        self.service = service
        self.secureNotesDetailNavigationBarModelFactory = secureNotesDetailNavigationBarModelFactory
        self.secureNotesDetailFieldsModelFactory = secureNotesDetailFieldsModelFactory
        self.secureNotesDetailToolbarFactory = secureNotesDetailToolbarFactory
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
        guard (mode.isAdding || mode.isEditing), canSave else { return }
        save()
    }

    func makeAttachmentsListViewModel() -> AttachmentsListViewModel? {
        let publisher = service.vaultItemsService
            .itemPublisher(for: item)
            .map { $0 as VaultItem }
            .eraseToAnyPublisher()
        return attachmentsListViewModelFactory.make(editingItem: item, itemPublisher: publisher)
    }
}
