import Combine
import CorePersonalData
import CoreSession
import CoreSettings
import CoreTypes
import Foundation
import IconLibrary
import UserTrackingFoundation
import VaultKit

class VPNMainViewModel: ObservableObject, SessionServicesInjecting {

  enum VPNMainViewMode {
    case activationNeeded
    case activated
  }

  @Published var mode: VPNMainViewMode = .activationNeeded

  @Published
  var hasDismissedNewProviderMessage = false

  private let actionPublisher: PassthroughSubject<VPNAvailableToolsFlowViewModel.Action, Never>?

  @Published var credential: VaultItem?

  let iconService: IconServiceProtocol
  private let vaultItemsStore: VaultItemsStore

  private var subscriptions = Set<AnyCancellable>()
  private var copyActionSubscription: AnyCancellable?
  private let accessControl: AccessControlHandler
  private let pasteboardService: PasteboardServiceProtocol
  private let userSettings: UserSettings
  private let activityReporter: ActivityReporterProtocol

  var action: () -> Void {
    switch mode {
    case .activationNeeded: return self.activateAccount
    case .activated: return self.openApp
    }
  }

  init(
    mode: VPNMainViewModel.VPNMainViewMode,
    credential: Credential? = nil,
    vaultItemsStore: VaultItemsStore,
    userSettings: UserSettings,
    activityReporter: ActivityReporterProtocol,
    accessControl: AccessControlHandler,
    iconService: IconServiceProtocol,
    pasteboardService: PasteboardServiceProtocol,
    actionPublisher: PassthroughSubject<VPNAvailableToolsFlowViewModel.Action, Never>? = nil
  ) {
    self.mode = mode
    self.actionPublisher = actionPublisher
    self.credential = credential
    self.iconService = iconService
    self.vaultItemsStore = vaultItemsStore
    self.userSettings = userSettings
    self.activityReporter = activityReporter
    self.accessControl = accessControl
    self.pasteboardService = pasteboardService
    self.vaultItemsStore.$credentials
      .receive(on: DispatchQueue.main)
      .map { $0.filter { $0.url?.host == VPNService.vpnCredentialURL.host } }
      .sink {
        if $0.count > 0 {
          self.mode = .activated
          self.credential = $0.first
        }
      }.store(in: &subscriptions)

    userSettings.publisher(for: .hasDismissedNewVPNProviderMessage)
      .compactMap { $0 }
      .assign(to: &$hasDismissedNewProviderMessage)
  }

  func copy(_ value: String, fieldType: DetailFieldType) {
    guard let item = credential else { return }

    pasteboardService.copy(value)
    sendCopyUsageLog(for: fieldType)
  }

  func sendCopyUsageLog(for fieldType: DetailFieldType) {
    guard let item = credential else { return }

    let isProtected = item is SecureItem
    activityReporter.report(
      UserEvent.CopyVaultItemField(
        field: fieldType.definitionField,
        isProtected: isProtected,
        itemId: item.userTrackingLogID,
        itemType: item.vaultItemType))
  }

  func activateAccount() {
    actionPublisher?.send(.activateAccount)
  }

  func openApp() {
    actionPublisher?.send(.openApp)
  }

  func dismissNewProviderMessage() {
    userSettings[.hasDismissedNewVPNProviderMessage] = true
  }

  static func mock(mode: VPNMainViewMode, credential: Credential? = nil) -> VPNMainViewModel {
    let container = MockServicesContainer()

    var credential = Credential()
    credential.url = PersonalDataURL(rawValue: VPNService.vpnCredentialURL.absoluteString)
    credential.password = "VPNPass"
    credential.login = "_"
    _ = try? container.database.save(credential)

    return VPNMainViewModel(
      mode: mode,
      vaultItemsStore: MockVaultKitServicesContainer().vaultItemsStore,
      userSettings: KeyedSettings(internalStore: .mock()),
      activityReporter: .mock,
      accessControl: .mock(),
      iconService: IconServiceMock(),
      pasteboardService: .mock())
  }
}
