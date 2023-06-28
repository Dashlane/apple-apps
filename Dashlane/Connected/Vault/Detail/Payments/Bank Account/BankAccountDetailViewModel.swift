import Foundation
import CorePersonalData
import Combine
import DocumentServices
import DashTypes
import DashlaneAppKit
import CoreUserTracking
import CoreSettings
import VaultKit
import UIComponents

class BankAccountDetailViewModel: DetailViewModelProtocol, SessionServicesInjecting, MockVaultConnectedInjecting {

    let regionInformationService: RegionInformationService

    var banks: [BankCodeNamePair] {
        regionInformationService.bankInfo.banks(forCountryCode: self.item.country?.code)
    }

    var selectedBank: BankCodeNamePair? {
        get {
            guard let bank = item.bank else {
                return banks.first
            }
            return bank
        } set {
            item.bank = newValue
        }
    }

    var selectedCountry: CountryCodeNamePair? {
        get {
            guard let country = item.country else {
                return CountryCodeNamePair.defaultCountry
            }
            return country
        } set {
            item.bank = nil
            item.country = newValue
        }
    }

    let service: DetailService<BankAccount>

    private var cancellables: Set<AnyCancellable> = []
    private let vaultItemsService: VaultItemsServiceProtocol

    convenience init(
        item: BankAccount,
        mode: DetailMode = .viewing,
        vaultItemsService: VaultItemsServiceProtocol,
        sharingService: SharedVaultHandling,
        teamSpacesService: TeamSpacesService,
        deepLinkService: VaultKit.DeepLinkingServiceProtocol,
        activityReporter: ActivityReporterProtocol,
        iconViewModelProvider: @escaping (VaultItem) -> VaultItemIconViewModel,
        logger: Logger,
        accessControl: AccessControlProtocol,
        regionInformationService: RegionInformationService,
        userSettings: UserSettings,
        documentStorageService: DocumentStorageService,
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
            ),
            regionInformationService: regionInformationService
        )
    }

    init(
        service: DetailService<BankAccount>,
        regionInformationService: RegionInformationService
    ) {
        self.service = service
        self.vaultItemsService = service.vaultItemsService
        self.regionInformationService = regionInformationService

        registerServiceChanges()
        setupDefaultInfo()
    }

    private func registerServiceChanges() {
        service
            .objectWillChange
            .sink { [weak self] in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    private func setupDefaultInfo() {
        guard mode.isAdding,
            let identity = vaultItemsService.identities.first,
              identity.personalTitle != .noneOfThese else {
                return
        }
        item.owner = "\(identity.personalTitle.localizedString) \(identity.firstName) \(identity.lastName)"
    }
}
