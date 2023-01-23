import Foundation
import CorePersonalData
import DashlaneReportKit
import DashTypes
import DashlaneAppKit
import Combine
import DocumentServices
import CoreUserTracking
import CoreSettings
import VaultKit

class IdentityDetailViewModel: DetailViewModelProtocol, SessionServicesInjecting, MockVaultConnectedInjecting {

    let service: DetailService<Identity>
    let logger: IdentityDetailUsageLogger

    private var cancellables: Set<AnyCancellable> = []

    convenience init(
        item: Identity,
        mode: DetailMode = .viewing,
        vaultItemsService: VaultItemsServiceProtocol,
        sharingService: SharedVaultHandling,
        teamSpacesService: TeamSpacesService,
        usageLogService: UsageLogServiceProtocol,
        documentStorageService: DocumentStorageService,
        deepLinkService: DeepLinkingServiceProtocol,
        activityReporter: ActivityReporterProtocol,
        iconViewModelProvider: @escaping (VaultItem) -> VaultItemIconViewModel,
        logger: Logger,
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
            )
        )
    }

    init(
        service: DetailService<Identity>
    ) {
        self.service = service
        self.logger = IdentityDetailUsageLogger(usageLogService: service.usageLogService)
        registerServiceChanges()
    }

    private func registerServiceChanges() {
        service
            .objectWillChange
            .sink { [weak self] in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    func prepareForSaving() throws {
        try service.prepareForSaving()
        logger.logIdentity(item: item)
    }
}
