import Foundation
import CorePersonalData
import DashTypes
import DashlaneAppKit
import Combine
import DocumentServices
import CoreUserTracking
import CoreSettings
import VaultKit
import UIComponents
import CoreLocalization

class EmailDetailViewModel: DetailViewModelProtocol, SessionServicesInjecting, MockVaultConnectedInjecting {

    let service: DetailService<CorePersonalData.Email>

    private var cancellables: Set<AnyCancellable> = []
    private let vaultItemsService: VaultItemsServiceProtocol

    convenience init(
        item: CorePersonalData.Email,
        mode: DetailMode = .viewing,
        vaultItemsService: VaultItemsServiceProtocol,
        sharingService: SharedVaultHandling,
        teamSpacesService: TeamSpacesService,
        documentStorageService: DocumentStorageService,
        deepLinkService: VaultKit.DeepLinkingServiceProtocol,
        activityReporter: ActivityReporterProtocol,
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
            )
        )
    }

    init(
        service: DetailService<CorePersonalData.Email>
    ) {
        self.service = service
        self.vaultItemsService = service.vaultItemsService

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
            let count = vaultItemsService.emails.count + 1
            item.name = "\(CoreLocalization.L10n.Core.kwEmailIOS) \(count)"
        }
    }
}
