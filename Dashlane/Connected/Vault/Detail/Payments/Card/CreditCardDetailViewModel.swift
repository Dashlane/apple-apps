import Foundation
import CorePersonalData
import Combine
import SwiftUI
import DashTypes
import DocumentServices
import DashlaneAppKit
import CoreUserTracking
import CoreSettings
import VaultKit

class CreditCardDetailViewModel: DetailViewModelProtocol, SessionServicesInjecting, MockVaultConnectedInjecting {

    let regionInformationService: RegionInformationService
    let logger: CreditCardUsageLogger

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
            item.country
        }
        set {
            item.bank = nil
            item.country = newValue
        }
    }

    var navigationBarColor: SwiftUI.Color? {
        return item.color.color
    }

    var selectedAddress: Address? {
        get {
            addresses.filter {
                $0.id == item.linkedBillingAddress
            }.first
        }
        set {
            self.item.linkedBillingAddress = newValue?.id
        }
    }

    var addresses: [Address] = []

    let service: DetailService<CreditCard>

    private var cancellables: Set<AnyCancellable> = []
    private var vaultItemsService: VaultItemsServiceProtocol

    convenience init(item: CreditCard,
                     mode: DetailMode = .viewing,
                     vaultItemsService: VaultItemsServiceProtocol,
                     sharingService: SharedVaultHandling,
                     teamSpacesService: TeamSpacesService,
                     usageLogService: UsageLogServiceProtocol,
                     deepLinkService: DeepLinkingServiceProtocol,
                     activityReporter: ActivityReporterProtocol,
                     iconViewModelProvider: @escaping (VaultItem) -> VaultItemIconViewModel,
                     logger: Logger,
                     accessControl: AccessControlProtocol,
                     regionInformationService: RegionInformationService,
                     userSettings: UserSettings,
                     documentStorageService: DocumentStorageService,
                     attachmentSectionFactory: AttachmentsSectionViewModel.Factory,
                     attachmentsListViewModelProvider: @escaping (VaultItem, AnyPublisher<VaultItem, Never>) -> AttachmentsListViewModel,
                     dismiss: (() -> Void)? = nil
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
        service: DetailService<CreditCard>,
        regionInformationService: RegionInformationService
    ) {
        self.service = service
        self.vaultItemsService = service.vaultItemsService
        self.regionInformationService = regionInformationService
        self.logger = CreditCardUsageLogger(usageLogService: service.usageLogService)

        registerServiceChanges()
        fetchAddresses()
        setupInfo()
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
        logger.logCreditCardDetails(item: item, action: mode.isAdding ? .add : .edit)
    }

    func delete() async {
        await service.delete()
        logger.logCreditCardDetails(item: item, action: .remove)
    }

    private func fetchAddresses() {
        addresses = vaultItemsService.addresses
        vaultItemsService
            .itemsPublisher(for: Address.self)
            .assign(to: \.addresses, on: self)
            .store(in: &cancellables)
    }

    private func setupInfo() {
        if mode.isAdding {
            let count = vaultItemsService.creditCards.count + 1
            item.name = "\(L10n.Localizable.kwPaymentMeanCreditCardIOS) \(count)"

            guard mode.isAdding,
                let identity = vaultItemsService.identities.first,
                  identity.personalTitle != .noneOfThese else {
                    return
            }
            item.ownerName = "\(identity.personalTitle.localizedString) \(identity.firstName) \(identity.lastName)"
        }
    }
}
