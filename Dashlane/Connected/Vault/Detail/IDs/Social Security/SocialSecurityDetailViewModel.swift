import Foundation
import SwiftUI
import CorePersonalData
import CorePasswords
import DashTypes
import Combine
import DocumentServices
import DashlaneAppKit
import CoreUserTracking
import CoreSettings
import VaultKit
import UIComponents

class SocialSecurityDetailViewModel: DetailViewModelProtocol, SessionServicesInjecting, MockVaultConnectedInjecting {

    var identities: [Identity] = []

        var displayFullName: String {
        linkedIdentityFullName ?? item.fullname
    }

    let service: DetailService<SocialSecurityInformation>

    private var linkedIdentityFullName: String? {
        let names = [item.linkedIdentity?.firstName, item.linkedIdentity?.lastName].compactMap { $0 }
        return names.isEmpty ? nil : names.joined(separator: " ")
    }

    private var cancellables: Set<AnyCancellable> = []
    private var vaultItemsService: VaultItemsServiceProtocol {
        service.vaultItemsService
    }

    convenience init(
        item: SocialSecurityInformation,
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
        service: DetailService<SocialSecurityInformation>
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
