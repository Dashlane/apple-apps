import AuthenticationServices
import AutofillKit
import CoreFeature
import CorePersonalData
import CorePremium
import CoreSettings
import CoreTeamAuditLogs
import CoreTypes
import DashlaneAPI
import DomainParser
import Foundation
import LogFoundation
import LoginKit
import PremiumKit
import UserTrackingFoundation
import VaultKit

@MainActor
class ContextMenuVaultItemsProviderFlowModel: ObservableObject, SessionServicesInjecting {
  enum Step {
    case list(ItemCategory?)
    case detailView(VaultItem)
    case frozen
  }

  @Published var steps: [Step] = [.list(nil)]
  @Published var selection: CredentialSelection?
  @Published var activeFilter: ItemCategory?

  let environmentModelFactory: AutofillConnectedEnvironmentModel.Factory
  let accessControlModelFactory: AccessControlRequestViewModifierModel.Factory

  private let autofillProvider: AutofillProvider
  private let vaultItemDatabase: VaultItemDatabaseProtocol
  private let accessControl: AccessControlHandler
  private let activityReporter: ActivityReporterProtocol
  private let contextMenuListViewModelFactory: ContextMenuListViewModel.Factory
  private let detailViewModelFactory: ContextMenuDetailViewModel.Factory

  init(
    autofillProvider: AutofillProvider,
    logger: Logger,
    database: ApplicationDatabase,
    featureService: FeatureServiceProtocol,
    userSpacesService: UserSpacesService,
    teamAuditLogsService: TeamAuditLogsServiceProtocol,
    vaultStateService: VaultStateServiceProtocol,
    accessControl: AccessControlHandler,
    activityReporter: ActivityReporterProtocol,
    contextMenuListViewModelFactory: ContextMenuListViewModel.Factory,
    detailViewModelFactory: ContextMenuDetailViewModel.Factory,
    environmentModelFactory: AutofillConnectedEnvironmentModel.Factory,
    nitroEncryptionAPIClient: UserSecureNitroEncryptionAPIClient,
    accessControlModelFactory: AccessControlRequestViewModifierModel.Factory
  ) {
    self.autofillProvider = autofillProvider
    self.accessControl = accessControl
    self.activityReporter = activityReporter
    self.contextMenuListViewModelFactory = contextMenuListViewModelFactory
    self.detailViewModelFactory = detailViewModelFactory
    self.environmentModelFactory = environmentModelFactory
    self.accessControlModelFactory = accessControlModelFactory
    let fakeSharingService = TachyonSharingService()
    self.vaultItemDatabase = VaultItemDatabase(
      logger: logger,
      database: database,
      sharingService: fakeSharingService,
      featureService: featureService,
      userSpacesService: userSpacesService,
      teamAuditLogsService: teamAuditLogsService,
      cloudPasskeyService: nitroEncryptionAPIClient.passkeys)

    vaultStateService
      .vaultStatePublisher()
      .filter { $0 == .frozen }
      .removeDuplicates()
      .map { _ in [.frozen] }
      .receive(on: DispatchQueue.main)
      .assign(to: &$steps)
  }

  func showDetail(for item: VaultItem, highlight: Definition.Highlight) {
    accessControl.requestAccess(to: item) { [weak self] success in
      guard success else {
        return
      }
      self?.activityReporter.report(
        UserEvent.SelectVaultItem(
          highlight: highlight, itemId: item.userTrackingLogID, itemType: item.vaultItemType))
      self?.steps.append(.detailView(item))
    }
  }
}

@available(iOS 18, *)
@available(macCatalyst, unavailable)
@available(visionOS, unavailable)
extension ContextMenuVaultItemsProviderFlowModel {
  func makeContextMenuListViewModel(category: ItemCategory?) -> ContextMenuListViewModel {
    contextMenuListViewModelFactory.make(
      activeFilter: category, vaultItemDatabase: vaultItemDatabase
    ) { [weak self] completion in
      switch completion {
      case let .enterDetail(item, highlight):
        self?.showDetail(for: item, highlight: highlight)
      case .cancel:
        self?.autofillProvider.cancel()
      }
    }
  }

  func makeDetailViewModel() -> ContextMenuDetailViewModel {
    detailViewModelFactory.make(vaultItemDatabase: vaultItemDatabase) {
      [weak self] vaultItem, text in
      Task {
        await self?.autofillProvider.autofillText(with: vaultItem, text)
      }
    }
  }
}
