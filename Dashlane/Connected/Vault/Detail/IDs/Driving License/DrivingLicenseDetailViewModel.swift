import Combine
import CoreActivityLogs
import CorePasswords
import CorePersonalData
import CorePremium
import CoreRegion
import CoreSettings
import CoreUserTracking
import DashTypes
import DocumentServices
import Foundation
import SwiftUI
import UIComponents
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
    vaultItemDatabase: VaultItemDatabaseProtocol,
    vaultItemsStore: VaultItemsStore,
    vaultCollectionDatabase: VaultCollectionDatabaseProtocol,
    vaultCollectionsStore: VaultCollectionsStore,
    sharingService: SharedVaultHandling,
    userSpacesService: UserSpacesService,
    deepLinkService: VaultKit.DeepLinkingServiceProtocol,
    activityReporter: ActivityReporterProtocol,
    activityLogsService: ActivityLogsServiceProtocol,
    regionInformationService: RegionInformationService,
    iconViewModelProvider: @escaping (VaultItem) -> VaultItemIconViewModel,
    logger: Logger,
    accessControl: AccessControlProtocol,
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
