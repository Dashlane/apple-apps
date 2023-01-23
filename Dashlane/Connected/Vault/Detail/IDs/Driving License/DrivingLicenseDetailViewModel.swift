import Foundation
import SwiftUI
import CorePersonalData
import CorePasswords
import DashTypes
import Combine
import CoreRegion
import DashlaneAppKit
import DocumentServices
import CoreUserTracking
import CoreSettings
import VaultKit

class DrivingLicenseDetailViewModel: DetailViewModelProtocol, SessionServicesInjecting, MockVaultConnectedInjecting {

    var identities: [Identity] = []

        var displayFullName: String {
        linkedIdentityFullName ?? item.fullname
    }

    private var linkedIdentityFullName: String? {
        let names = [item.linkedIdentity?.firstName, item.linkedIdentity?.lastName].compactMap { $0 }
        return names.isEmpty ? nil : names.joined(separator: " ")
    }

    var stateItems: [StateCodeNamePair] {
      regionInformationService.geoInfo.states(for: self.item)
    }

    let service: DetailService<DrivingLicence>

    private var cancellables: Set<AnyCancellable> = []
    let regionInformationService: RegionInformationService

    private var vaultItemsService: VaultItemsServiceProtocol {
        service.vaultItemsService
    }

    convenience init(
        item: DrivingLicence,
        mode: DetailMode = .viewing,
        vaultItemsService: VaultItemsServiceProtocol,
        sharingService: SharedVaultHandling,
        teamSpacesService: TeamSpacesService,
        usageLogService: UsageLogServiceProtocol,
        deepLinkService: DeepLinkingServiceProtocol,
        activityReporter: ActivityReporterProtocol,
        regionInformationService: RegionInformationService,
        iconViewModelProvider: @escaping (VaultItem) -> VaultItemIconViewModel,
        logger: Logger,
        accessControl: AccessControlProtocol,
        userSettings: UserSettings,
        documentStorageService: DocumentStorageService,
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
            regionInformationService: regionInformationService
        )
    }

    init(
        service: DetailService<DrivingLicence>,
        regionInformationService: RegionInformationService
    ) {
        self.service = service
        self.regionInformationService = regionInformationService

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

extension RegionInformationManager where T == GeographicalState {
    func states(for drivingLicense: DrivingLicence) -> [StateCodeNamePair] {
        guard let code = drivingLicense.country?.code else {
            return []
        }
        let items = self.items(forCode: code).map {
            StateCodeNamePair(components: RegionCodeComponentsInfo(countryCode: code,
                                                                   subcode: $0.code),
                              name: $0.localizedString)
        }
        return items
    }
}
