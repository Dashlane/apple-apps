import Combine
import CoreActivityLogs
import CoreFeature
import CoreLocalization
import CorePersonalData
import CorePremium
import CoreSession
import CoreSettings
import CoreUserTracking
import DashTypes
import DocumentServices
import Foundation
import SwiftUI
import UIComponents
import VaultKit

class CreditCardDetailViewModel: DetailViewModelProtocol, SessionServicesInjecting,
  MockVaultConnectedInjecting
{

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
    }
    set {
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
  private var vaultItemsStore: VaultItemsStore {
    service.vaultItemsStore
  }

  convenience init(
    item: CreditCard,
    mode: DetailMode = .viewing,
    session: Session,
    vaultItemDatabase: VaultItemDatabaseProtocol,
    vaultItemsStore: VaultItemsStore,
    vaultCollectionDatabase: VaultCollectionDatabaseProtocol,
    vaultCollectionsStore: VaultCollectionsStore,
    vaultStateService: VaultStateServiceProtocol,
    sharingService: SharedVaultHandling,
    userSpacesService: UserSpacesService,
    deepLinkService: VaultKit.DeepLinkingServiceProtocol,
    activityReporter: ActivityReporterProtocol,
    activityLogsService: ActivityLogsServiceProtocol,
    iconViewModelProvider: @escaping (VaultItem) -> VaultItemIconViewModel,
    logger: Logger,
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
        canLock: session.authenticationMethod.supportsLock,
        mode: mode,
        vaultItemDatabase: vaultItemDatabase,
        vaultItemsStore: vaultItemsStore,
        vaultStateService: vaultStateService,
        vaultCollectionDatabase: vaultCollectionDatabase,
        vaultCollectionsStore: vaultCollectionsStore,
        sharingService: sharingService,
        userSpacesService: userSpacesService,
        documentStorageService: documentStorageService,
        deepLinkService: deepLinkService,
        activityReporter: activityReporter,
        activityLogsService: activityLogsService,
        iconViewModelProvider: iconViewModelProvider,
        attachmentSectionFactory: attachmentSectionFactory,
        logger: logger,
        userSettings: userSettings,
        pasteboardService: pasteboardService
      ),
      regionInformationService: regionInformationService
    )
  }

  init(
    service: DetailService<CreditCard>,
    regionInformationService: RegionInformationService
  ) {
    self.service = service
    self.regionInformationService = regionInformationService

    registerServiceChanges()
    fetchAddresses()
    setupInfo()
  }

  private func registerServiceChanges() {
    service
      .objectWillChange
      .receive(on: DispatchQueue.main)
      .sink { [weak self] in
        self?.objectWillChange.send()
      }
      .store(in: &cancellables)
  }

  func prepareForSaving() throws {
    try service.prepareForSaving()
  }

  func delete() async {
    await service.delete()
  }

  private func fetchAddresses() {
    addresses = vaultItemsStore.addresses
    vaultItemsStore.$addresses
      .assign(to: \.addresses, on: self)
      .store(in: &cancellables)
  }

  private func setupInfo() {
    if mode.isAdding {
      let count = vaultItemsStore.creditCards.count + 1
      item.name = "\(CoreLocalization.L10n.Core.kwPaymentMeanCreditCardIOS) \(count)"

      guard mode.isAdding,
        let identity = vaultItemsStore.identities.first,
        identity.personalTitle != .noneOfThese
      else {
        return
      }
      item.ownerName =
        "\(identity.personalTitle.localizedString) \(identity.firstName) \(identity.lastName)"
    }
  }
}
