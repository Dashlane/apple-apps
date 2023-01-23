import Foundation
import SwiftUI
import CorePersonalData
import CorePasswords
import DashTypes
import Combine
import DashlaneAppKit
import DocumentServices
import CoreUserTracking
import CoreSettings
import VaultKit

class PassportDetailViewModel: DetailViewModelProtocol, SessionServicesInjecting, MockVaultConnectedInjecting {

    var identities: [Identity] = []

        var displayFullName: String {
        linkedIdentityFullName ?? item.fullname
    }

    let service: DetailService<Passport>

    private var linkedIdentityFullName: String? {
        let names = [item.linkedIdentity?.firstName, item.linkedIdentity?.lastName].compactMap { $0 }
        return names.isEmpty ? nil : names.joined(separator: " ")
    }

    private var vaultItemsService: VaultItemsServiceProtocol {
        service.vaultItemsService
    }

    private var cancellables: Set<AnyCancellable> = []

    convenience init(
        item: Passport,
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
        service: DetailService<Passport>
    ) {
        self.service = service

        registerServiceChanges()
        setupIdentities()
    }

    private func registerServiceChanges() {
        service
            .objectWillChange
            .sink { [weak self] in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    private func setupIdentities() {
        vaultItemsService
            .itemsPublisher(for: Identity.self)
            .assign(to: \.identities, on: self)
            .store(in: &cancellables)
        if mode.isAdding {
            item.linkedIdentity = identities.first
        }
        identities = vaultItemsService.identities
    }
}
