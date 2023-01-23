import Foundation
import CorePersonalData
import SwiftUI
import CoreSession
import DashlaneReportKit
import DashTypes
import Combine
import DashlaneAppKit
import DocumentServices
import CoreUserTracking
import CoreSettings
import VaultKit
import CoreFeature

class SecureNotesDetailViewModel: DetailViewModelProtocol, SessionServicesInjecting, MockVaultConnectedInjecting {

    private var deleteAttachmentsSubscriber: AnyCancellable?
    let logger: SecureNotesDetailUsageLogger

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

    private var teamSpacesService: TeamSpacesService {
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
        usageLogService: UsageLogServiceProtocol,
        deepLinkService: DeepLinkingServiceProtocol,
        activityReporter: ActivityReporterProtocol,
        iconViewModelProvider: @escaping (VaultItem) -> VaultItemIconViewModel,
        secureNotesDetailNavigationBarModelFactory: SecureNotesDetailNavigationBarModel.Factory,
        secureNotesDetailFieldsModelFactory: SecureNotesDetailFieldsModel.Factory,
        secureNotesDetailToolbarModelFactory: SecureNotesDetailToolbarModel.Factory,
        sharingMembersDetailLinkModelFactory: SharingMembersDetailLinkModel.Factory,
        shareButtonViewModelFactory: ShareButtonViewModel.Factory,
        logger: Logger,
        documentStorageService: DocumentStorageService,
        accessControl: AccessControlProtocol,
        userSettings: UserSettings,
        attachmentSectionFactory: AttachmentsSectionViewModel.Factory,
        attachmentsListViewModelProvider: @escaping (VaultItem, AnyPublisher<VaultItem, Never>) -> AttachmentsListViewModel
    ) {
        self.init(
            service: .init(
                item: item,
                mode: mode,
                vaultItemsService: vaultItemsService,
                sharingService: sharingService,
                teamSpacesService: teamSpacesService,
                usageLogService: usageLogService,
                documentStorageService: documentStorageService,
                deepLinkService: deepLinkService,
                activityReporter: activityReporter,
                iconViewModelProvider: iconViewModelProvider,
                logger: logger,
                accessControl: accessControl,
                userSettings: userSettings,
                attachmentSectionFactory: attachmentSectionFactory,
                attachmentsListViewModelProvider: attachmentsListViewModelProvider
            ),
            secureNotesDetailNavigationBarModelFactory: secureNotesDetailNavigationBarModelFactory,
            secureNotesDetailFieldsModelFactory: secureNotesDetailFieldsModelFactory,
            secureNotesDetailToolbarFactory: secureNotesDetailToolbarModelFactory,
            sharingMembersDetailLinkModelFactory: sharingMembersDetailLinkModelFactory,
            shareButtonViewModelFactory: shareButtonViewModelFactory
        )
    }

    init(
        service: DetailService<SecureNote>,
        secureNotesDetailNavigationBarModelFactory: SecureNotesDetailNavigationBarModel.Factory,
        secureNotesDetailFieldsModelFactory: SecureNotesDetailFieldsModel.Factory,
        secureNotesDetailToolbarFactory: SecureNotesDetailToolbarModel.Factory,
        sharingMembersDetailLinkModelFactory: SharingMembersDetailLinkModel.Factory,
        shareButtonViewModelFactory: ShareButtonViewModel.Factory
    ) {
        self.service = service
        self.secureNotesDetailNavigationBarModelFactory = secureNotesDetailNavigationBarModelFactory
        self.secureNotesDetailFieldsModelFactory = secureNotesDetailFieldsModelFactory
        self.secureNotesDetailToolbarFactory = secureNotesDetailToolbarFactory
        self.sharingMembersDetailLinkModelFactory = sharingMembersDetailLinkModelFactory
        self.shareButtonViewModelFactory = shareButtonViewModelFactory
        self.logger = SecureNotesDetailUsageLogger(usageLogService: service.usageLogService)

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
}
