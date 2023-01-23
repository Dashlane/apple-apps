import SwiftUI
import CorePersonalData
import CorePasswords
import DashTypes
import DashlaneAppKit
import Combine
import DocumentServices
import CoreUserTracking
import CoreSettings
import VaultKit

class FiscalInformationDetailViewModel: DetailViewModelProtocol, SessionServicesInjecting, MockVaultConnectedInjecting {

    let service: DetailService<FiscalInformation>

    private var cancellables: Set<AnyCancellable> = []

    convenience init(
        item: FiscalInformation,
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
        service: DetailService<FiscalInformation>
    ) {
        self.service = service
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
}
