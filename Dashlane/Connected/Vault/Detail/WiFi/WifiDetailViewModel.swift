import Combine
import CorePersonalData
import CorePremium
import CoreSession
import CoreSettings
import CoreTeamAuditLogs
import CoreTypes
import DocumentServices
import LogFoundation
import NetworkExtension
import SwiftUI
import UIComponents
import UserTrackingFoundation
import VaultKit

public final class WifiDetailViewModel: DetailViewModelProtocol, SessionServicesInjecting,
  MockVaultConnectedInjecting
{

  public let service: DetailService<WiFi>

  @Published var showQRCodeSheet: Bool = false

  private var userSpacesService: UserSpacesService {
    service.userSpacesService
  }

  private var cancellables: Set<AnyCancellable> = []

  @Published private(set) var isConnecting = false

  convenience init(
    item: WiFi,
    session: Session,
    mode: DetailMode = .viewing,
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
    documentStorageService: DocumentStorageService,
    sharingDetailSectionModelFactory: SharingDetailSectionModel.Factory,
    pasteboardService: PasteboardServiceProtocol,
    iconViewModelProvider: @escaping (VaultItem) -> VaultItemIconViewModel,
    attachmentsListViewModelFactory: AttachmentsListViewModel.Factory,
    attachmentSectionFactory: AttachmentsSectionViewModel.Factory,
    logger: Logger,
    userSettings: UserSettings
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
      )
    )
  }

  init(service: DetailService<WiFi>) {
    self.service = service
    registerServiceChanges()
    setupAutoSave()
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
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

  private func setupAutoSave() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(autoSave),
      name: UIApplication.applicationWillResignActiveNotification,
      object: nil
    )
  }

  @objc private func autoSave() {
    guard mode.isAdding || mode.isEditing, canSave else { return }
    Task { @MainActor in
      await save()
    }
  }

  public func makeWifiQRCodeViewModel() -> WifiQRCodeViewModel {
    .init(service: service)
  }

  public func showQRCodeView() {
    showQRCodeSheet.toggle()
    if showQRCodeSheet {
      service.activityReporter.report(
        UserEvent.UseVaultItem(
          action: .displayQrCode,
          fieldsUsed: [.networkName, .password],
          itemId: String(describing: self.item.userTrackingLogID),
          itemType: .wifi))
    }
  }

  public func connect() {
    #if HOTSPOT_ENTITLED
      isConnecting = true

      let confiuguration =
        if item.passphrase.isEmpty {
          NEHotspotConfiguration(ssid: item.ssid)
        } else {
          NEHotspotConfiguration(ssid: item.ssid, passphrase: item.passphrase, isWEP: false)
        }

      Task { @MainActor [weak self] in
        defer { self?.isConnecting = false }
        do {
          try await NEHotspotConfigurationManager.shared.apply(confiuguration)
          self?.eventPublisher.send(.wifiConnection)
          self?.service.activityReporter.report(
            UserEvent.UseVaultItem(
              action: .connect,
              fieldsUsed: [.networkName, .password],
              itemId: String(describing: self?.item.id),
              itemType: .wifi)
          )
        } catch let error where error.isAlreadyAssociatedError {
          self?.eventPublisher.send(.wifiConnection)
        }
      }
    #endif
  }
}

extension Error {
  fileprivate var isAlreadyAssociatedError: Bool {
    let nsError = self as NSError
    return nsError.domain == NEHotspotConfigurationErrorDomain
      && nsError.code == NEHotspotConfigurationError.alreadyAssociated.rawValue
  }
}
