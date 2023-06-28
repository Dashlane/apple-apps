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

class PhoneDetailViewModel: DetailViewModelProtocol, SessionServicesInjecting, MockVaultConnectedInjecting {

    let service: DetailService<Phone>

    let regionInformationService: RegionInformationService

    private var cancellables: Set<AnyCancellable> = []
    private var vaultItemsService: VaultItemsServiceProtocol {
        service.vaultItemsService
    }

    convenience init(
        item: Phone,
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
        attachmentSectionFactory: AttachmentsSectionViewModel.Factory,
        regionInformationService: RegionInformationService
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
            regionInformationService: regionInformationService
        )
    }

    init(
        service: DetailService<Phone>,
        regionInformationService: RegionInformationService
    ) {
        self.service = service
        self.regionInformationService = regionInformationService

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

    func displayableCountry(forCountry country: CountryCodeNamePair) -> String {
        guard let code = regionInformationService.callingCodes.code(for: country)?.dialingCode else {
            return country.name
        }
        let phoneCode = "(+\(String(code)))"
        return [country.name, phoneCode ].joined(separator: " ")
    }

    private func setupName() {
        if mode.isAdding {
            let count = vaultItemsService.phones.count + 1
            item.name = "\(CoreLocalization.L10n.Core.kwPhoneIOS) \(count)"
        }
    }
}
