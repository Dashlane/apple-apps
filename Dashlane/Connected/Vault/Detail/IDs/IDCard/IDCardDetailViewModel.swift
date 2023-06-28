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
import UIComponents

class IDCardDetailViewModel: DetailViewModelProtocol, SessionServicesInjecting, MockVaultConnectedInjecting {

    var identities: [Identity] = []

        var displayFullName: String {
        self.item.linkedIdentity?.displayNameWithoutMiddleName ?? item.fullName
    }

    let service: DetailService<IDCard>

    private var cancellables: Set<AnyCancellable> = []
    private var vaultItemsService: VaultItemsServiceProtocol

    convenience init(
        item: IDCard,
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
        service: DetailService<IDCard>
    ) {
        self.service = service
        self.vaultItemsService = service.vaultItemsService

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
