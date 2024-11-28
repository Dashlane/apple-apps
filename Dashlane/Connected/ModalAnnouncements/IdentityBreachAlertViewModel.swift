import CoreFeature
import DashTypes
import Foundation
import SecurityDashboard

class IdentityBreachAlertViewModel: SessionServicesInjecting {
  let breaches: [PopupAlertProtocol]
  private let deepLinkingService: DeepLinkingService
  private let identityDashboardService: IdentityDashboardServiceProtocol
  private let featureService: FeatureServiceProtocol

  init(
    breachesToPresent: [PopupAlertProtocol],
    identityDashboardService: IdentityDashboardServiceProtocol,
    deepLinkingService: DeepLinkingService,
    featureService: FeatureServiceProtocol
  ) {
    self.breaches = breachesToPresent
    self.deepLinkingService = deepLinkingService
    self.identityDashboardService = identityDashboardService
    self.featureService = featureService
  }

  func updateBreachesStatus(for popups: [PopupAlertProtocol], to status: StoredBreach.Status) {
    Task {
      await identityDashboardService.mark(breaches: popups.map { $0.breach.id }, as: status)
    }
  }

  func updateBreachesStatus(for breachesId: [String], to status: StoredBreach.Status) {
    Task {
      await identityDashboardService.mark(breaches: breachesId, as: status)
    }
  }

  func handleAction(for button: AlertButton, on popup: PopupAlertProtocol) {
    switch button {
    case .close, .cancel, .later, .dismiss:
      updateBreachesStatus(for: [popup], to: .viewed)
    case .view, .takeAction:
      showDarkWebMonitoringSection()
      updateBreachesStatus(for: [popup], to: .viewed)
    case .upgrade:
      deepLinkingService.handleLink(.premium(.getPremium))
    case .viewDetails:
      updateBreachesStatus(for: [popup], to: .viewed)
      Task { @MainActor in
        let alerts = await identityDashboardService.trayAlerts()
        guard let alert = alerts.first(where: { $0.breach == popup.breach }) else {
          return
        }
        deepLinkingService.handleLink(.unresolvedAlert(alert))
      }

    }
  }

  func showDarkWebMonitoringSection() {
    let origin = PasswordHealthFlowViewModel.Origin.popupAlert.rawValue
    deepLinkingService.handleLink(.tool(.darkWebMonitoring, origin: origin))
  }
}
