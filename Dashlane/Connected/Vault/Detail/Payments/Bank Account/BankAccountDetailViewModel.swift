import Combine
import CoreFeature
import CorePersonalData
import CorePremium
import CoreSession
import CoreSettings
import CoreTeamAuditLogs
import CoreTypes
import DocumentServices
import Foundation
import LogFoundation
import UIComponents
import UserTrackingFoundation
import VaultKit

final class BankAccountDetailViewModel: DetailViewModelProtocol, SessionServicesInjecting,
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
      guard let country = item.country else {
        return CountryCodeNamePair.defaultCountry
      }
      return country
    }
    set {
      item.bank = nil
      item.country = newValue
    }
  }

  let service: DetailService<BankAccount>

  private var cancellables: Set<AnyCancellable> = []
  private var vaultItemsStore: VaultItemsStore {
    service.vaultItemsStore
  }

  convenience init(
    item: BankAccount,
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
    teamAuditLogsService: TeamAuditLogsServiceProtocol,
    iconViewModelProvider: @escaping (VaultItem) -> VaultItemIconViewModel,
    logger: Logger,
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
        teamAuditLogsService: teamAuditLogsService,
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
    service: DetailService<BankAccount>,
    regionInformationService: RegionInformationService
  ) {
    self.service = service
    self.regionInformationService = regionInformationService

    registerServiceChanges()
    setupDefaultInfo()
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

  private func setupDefaultInfo() {
    guard mode.isAdding,
      let identity = vaultItemsStore.identities.first,
      identity.personalTitle != .noneOfThese
    else { return }

    item.owner =
      "\(identity.personalTitle.localizedString) \(identity.firstName) \(identity.lastName)"
  }
}
