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
import UIComponents
import VaultKit

class PhoneDetailViewModel: DetailViewModelProtocol, SessionServicesInjecting,
  MockVaultConnectedInjecting
{

  let service: DetailService<Phone>

  let regionInformationService: RegionInformationService

  private var cancellables: Set<AnyCancellable> = []
  private var vaultItemsStore: VaultItemsStore {
    service.vaultItemsStore
  }

  convenience init(
    item: Phone,
    mode: DetailMode = .viewing,
    session: Session,
    vaultItemDatabase: VaultItemDatabaseProtocol,
    vaultItemsStore: VaultItemsStore,
    vaultCollectionDatabase: VaultCollectionDatabaseProtocol,
    vaultCollectionsStore: VaultCollectionsStore,
    vaultStateService: VaultStateServiceProtocol,
    sharingService: SharedVaultHandling,
    userSpacesService: UserSpacesService,
    documentStorageService: DocumentStorageService,
    deepLinkService: VaultKit.DeepLinkingServiceProtocol,
    activityReporter: ActivityReporterProtocol,
    activityLogsService: ActivityLogsServiceProtocol,
    iconViewModelProvider: @escaping (VaultItem) -> VaultItemIconViewModel,
    logger: Logger,
    userSettings: UserSettings,
    pasteboardService: PasteboardServiceProtocol,
    attachmentSectionFactory: AttachmentsSectionViewModel.Factory,
    regionInformationService: RegionInformationService
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
      .receive(on: DispatchQueue.main)
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
    return [country.name, phoneCode].joined(separator: " ")
  }

  private func setupName() {
    if mode.isAdding {
      let count = vaultItemsStore.phones.count + 1
      item.name = "\(CoreLocalization.L10n.Core.kwPhoneIOS) \(count)"
    }
  }
}
