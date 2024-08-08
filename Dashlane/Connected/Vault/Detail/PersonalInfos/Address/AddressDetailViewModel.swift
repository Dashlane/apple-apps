import Combine
import CoreActivityLogs
import CoreLocalization
import CorePersonalData
import CorePremium
import CoreSettings
import CoreUserTracking
import DashTypes
import DocumentServices
import Foundation
import UIComponents
import VaultKit

class AddressDetailViewModel: DetailViewModelProtocol, SessionServicesInjecting,
  MockVaultConnectedInjecting
{

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
  private var vaultItemsStore: VaultItemsStore {
    service.vaultItemsStore
  }

  convenience init(
    item: Address,
    mode: DetailMode = .viewing,
    vaultItemDatabase: VaultItemDatabaseProtocol,
    vaultItemsStore: VaultItemsStore,
    vaultCollectionDatabase: VaultCollectionDatabaseProtocol,
    vaultCollectionsStore: VaultCollectionsStore,
    sharingService: SharedVaultHandling,
    userSpacesService: UserSpacesService,
    deepLinkService: VaultKit.DeepLinkingServiceProtocol,
    activityReporter: ActivityReporterProtocol,
    iconViewModelProvider: @escaping (VaultItem) -> VaultItemIconViewModel,
    logger: Logger,
    accessControl: AccessControlProtocol,
    activityLogsService: ActivityLogsServiceProtocol,
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
        vaultItemDatabase: vaultItemDatabase,
        vaultItemsStore: vaultItemsStore,
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
    phoneList = vaultItemsStore.phones
    vaultItemsStore.$phones
      .assign(to: \.phoneList, on: self)
      .store(in: &cancellables)
  }

  private func setupName() {
    if mode.isAdding {
      let count = vaultItemsStore.addresses.count + 1
      item.name = "\(CoreLocalization.L10n.Core.kwAddressIOS) \(count)"
    }
  }

  func prepareForSaving() throws {
    try service.prepareForSaving()
  }
}
