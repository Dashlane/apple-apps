import Combine
import SecurityDashboard
import SwiftUI

class BreachPopupAlertModifierModel: ObservableObject, SessionServicesInjecting {
  enum BreachAlert: Identifiable {
    case single(PopupAlert)
    case grouped(ids: [String])

    var id: String {
      switch self {
      case .single(let alert):
        return alert.alert.breach.id
      case .grouped(let ids):
        return "\(ids.count)"
      }
    }
  }

  @Published
  var breachAlert: BreachAlert?

  private let identityDashboardService: IdentityDashboardServiceProtocol
  private let lockService: LockServiceProtocol
  private let deepLinkingService: DeepLinkingServiceProtocol

  init(
    identityDashboardService: IdentityDashboardServiceProtocol,
    lockService: LockServiceProtocol,
    deepLinkingService: DeepLinkingServiceProtocol
  ) {
    self.identityDashboardService = identityDashboardService
    self.lockService = lockService
    self.deepLinkingService = deepLinkingService

    configure()
  }

  private func configure() {
    let breachAlertPulibsher = identityDashboardService.breachesToPresentPublisher
      .debounce(for: 1, scheduler: DispatchQueue.main)
      .map { breaches -> BreachAlert? in
        guard let first = breaches.first else {
          return nil
        }

        return breaches.count > 1
          ? .grouped(ids: breaches.map(\.breach.id)) : .single(PopupAlert(first))
      }

    let lockGate: AnyPublisher<Bool, Never> =
      if let locker = lockService.locker.screenLocker {
        locker.$lock.map { $0 == nil }.eraseToAnyPublisher()
      } else {
        Just(true).eraseToAnyPublisher()
      }

    lockGate
      .combineLatest(breachAlertPulibsher) { (unlocked: Bool, breaches: BreachAlert?) in
        guard unlocked else {
          return nil
        }

        return breaches
      }
      .receive(on: DispatchQueue.main)
      .assign(to: &$breachAlert)
  }

  func updateBreachesStatus(for popups: [PopupAlertProtocol], to status: StoredBreach.Status) {
    Task {
      await identityDashboardService.mark(breaches: popups.map(\.breach.id), as: status)
    }
  }

  func updateBreachesStatus(for breachesId: [String], to status: StoredBreach.Status) {
    Task {
      await identityDashboardService.mark(breaches: breachesId, as: status)
    }
  }

  func showDarkWebMonitoringSection() {
    let origin = PasswordHealthFlowViewModel.Origin.popupAlert.rawValue
    deepLinkingService.handleLink(.tool(.darkWebMonitoring, origin: origin))
  }

  func handleAction(for button: AlertButton, on popup: PopupAlert) {
    switch button {
    case .close, .cancel, .later, .dismiss:
      updateBreachesStatus(for: [popup.alert], to: .viewed)
    case .view, .takeAction:
      showDarkWebMonitoringSection()
      updateBreachesStatus(for: [popup.alert], to: .viewed)
    case .upgrade:
      deepLinkingService.handleLink(.premium(.getPremium))
    case .viewDetails:
      updateBreachesStatus(for: [popup.alert], to: .viewed)
      Task { @MainActor in
        let alerts = await identityDashboardService.trayAlerts()
        guard let alert = alerts.first(where: { $0.breach == popup.alert.breach }) else {
          return
        }
        deepLinkingService.handleLink(.unresolvedAlert(alert))
      }

    }
  }
}
