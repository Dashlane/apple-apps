import Combine
import CoreFeature
import CorePasswords
import CorePersonalData
import CorePremium
import CoreRegion
import CoreSession
import CoreSettings
import CoreTeamAuditLogs
import CoreTypes
import DocumentServices
import Foundation
import LogFoundation
import SwiftUI
import UIComponents
import UserTrackingFoundation
import VaultKit

class DrivingLicenseDetailViewModel: DetailViewModelProtocol, SessionServicesInjecting,
  MockVaultConnectedInjecting
{

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

  private var vaultItemsStore: VaultItemsStore {
    service.vaultItemsStore
  }

  convenience init(
    item: DrivingLicence,
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
    regionInformationService: RegionInformationService,
    iconViewModelProvider: @escaping (VaultItem) -> VaultItemIconViewModel,
    logger: Logger,
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
      .receive(on: DispatchQueue.main)
      .sink { [weak self] in
        self?.objectWillChange.send()
      }
      .store(in: &cancellables)
  }

  private func setupIdentities() {
    vaultItemsStore.$identities
      .assign(to: \.identities, on: self)
      .store(in: &cancellables)
    if mode.isAdding {
      item.linkedIdentity = identities.first
    }
    identities = vaultItemsStore.identities
  }
}

extension RegionInformationManager where T == GeographicalState {
  func states(for drivingLicense: DrivingLicence) -> [StateCodeNamePair] {
    guard let code = drivingLicense.country?.code else {
      return []
    }
    let items = self.items(forCode: code).map {
      StateCodeNamePair(
        components: RegionCodeComponentsInfo(
          countryCode: code,
          subcode: $0.code),
        name: $0.localizedString)
    }
    return items
  }
}
