import Foundation
import CorePersonalData
import Combine
import SwiftUI
import DashTypes
import DocumentServices
import VaultKit
import UIComponents
import CoreSettings
import CoreUserTracking

class PasskeyDetailViewModel: DetailViewModelProtocol, SessionServicesInjecting, MockVaultConnectedInjecting {

    let service: DetailService<CorePersonalData.Passkey>

    private var cancellables: Set<AnyCancellable> = []

    enum Error: String, Swift.Error {
        case cannotChangePasskeyData
    }

    convenience init(
        item: CorePersonalData.Passkey,
        mode: DetailMode = .viewing,
        vaultItemsService: VaultItemsServiceProtocol,
        sharingService: SharedVaultHandling,
        teamSpacesService: TeamSpacesService,
        deepLinkService: VaultKit.DeepLinkingServiceProtocol,
        activityReporter: ActivityReporterProtocol,
        iconViewModelProvider: @escaping (VaultItem) -> VaultItemIconViewModel,
        logger: Logger,
        accessControl: AccessControlProtocol,
        userSettings: UserSettings,
        pasteboardService: PasteboardServiceProtocol,
        documentStorageService: DocumentStorageService,
        attachmentSectionFactory: AttachmentsSectionViewModel.Factory,
        dismiss: (() -> Void)? = nil
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
        service: DetailService<CorePersonalData.Passkey>
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

    func prepareForSaving() throws {
        guard originalItem.privateKey == item.privateKey,
              originalItem.credentialId == item.credentialId,
              originalItem.userHandle == item.userHandle,
              originalItem.userDisplayName == item.userDisplayName,
              originalItem.keyAlgorithm == item.keyAlgorithm,
              originalItem.relyingPartyId == item.relyingPartyId,
              originalItem.relyingPartyName == item.relyingPartyName else {
            throw Error.cannotChangePasskeyData
        }
        try service.prepareForSaving()
    }

    func delete() async {
        await service.delete()
    }

}
