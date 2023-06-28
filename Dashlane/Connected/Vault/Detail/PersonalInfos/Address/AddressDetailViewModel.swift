import Foundation
import CorePersonalData
import Combine
import DashTypes
import DocumentServices
import DashlaneAppKit
import CoreUserTracking
import CoreSettings
import VaultKit
import UIComponents
import CoreLocalization

class AddressDetailViewModel: DetailViewModelProtocol, SessionServicesInjecting, MockVaultConnectedInjecting {

    var selectedCountry: CountryCodeNamePair? {
        get {
            item.country
        }
        set {
            item.state = nil
            item.country = newValue
        }
    }

    var stateItems: [StateCodeNamePair] {
        regionInformationService.geoInfo.states(forCountryCode: self.item.country?.code)
    }

    var selectedPhone: Phone? {
        get {
            phoneList.filter {
                $0.id == item.linkedPhone
            }.first
        }
        set {
            self.item.linkedPhone = newValue?.id
        }
    }

    var phoneList: [Phone] = []

    let service: DetailService<Address>

    let regionInformationService: RegionInformationService

    private var cancellables: Set<AnyCancellable> = []
    private let vaultItemsService: VaultItemsServiceProtocol

    convenience init(
        item: Address,
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
            ),
            regionInformationService: regionInformationService
        )
    }

    init(
        service: DetailService<Address>,
        regionInformationService: RegionInformationService
    ) {
        self.service = service
        self.vaultItemsService = service.vaultItemsService
        self.regionInformationService = regionInformationService

        registerServiceChanges()
        fetchPhone()
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

    private func fetchPhone() {
        phoneList = vaultItemsService.phones
        vaultItemsService
            .itemsPublisher(for: Phone.self)
            .assign(to: \.phoneList, on: self)
            .store(in: &cancellables)
    }

    private func setupName() {
        if mode.isAdding {
            let count = vaultItemsService.addresses.count + 1
            item.name = "\(CoreLocalization.L10n.Core.kwAddressIOS) \(count)"
        }
    }

    func prepareForSaving() throws {
        try service.prepareForSaving()
    }
}
