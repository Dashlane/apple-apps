import Foundation
import SecurityDashboard
import DashlaneAppKit
import DashTypes
import CoreFeature

class IdentityBreachAlertViewModel: SessionServicesInjecting {
    let breaches: [PopupAlertProtocol]
    private let deepLinkingService: DeepLinkingService
    private let identityDashboardService: IdentityDashboardServiceProtocol
    private let featureService: FeatureServiceProtocol
    let logger: SecurityBreachLogger

    init(breachesToPresent: [PopupAlertProtocol],
         identityDashboardService: IdentityDashboardServiceProtocol,
         usageLogService: UsageLogServiceProtocol,
         deepLinkingService: DeepLinkingService,
         featureService: FeatureServiceProtocol) {
        self.breaches = breachesToPresent
        self.logger = SecurityBreachLogger(usageLogService: usageLogService)
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
                        deepLinkingService.handleLink(.other(.getPremium, origin: "dark_web"))
        case .viewDetails:
            let origin = PasswordHealthFlowViewModel.Origin.popupAlert.rawValue
            updateBreachesStatus(for: [popup], to: .viewed)
            Task { @MainActor in
                let alerts = await identityDashboardService.trayAlerts()
                guard let alert = alerts.first(where: { $0.breach == popup.breach }) else {
                    return
                }
                deepLinkingService.handleLink(.tool(.unresolvedAlert(alert), origin: origin))
            }

        }
        logAction(for: button, on: popup)
    }

    func showDarkWebMonitoringSection() {
        let origin = PasswordHealthFlowViewModel.Origin.popupAlert.rawValue
        deepLinkingService.handleLink(.tool(.darkWebMonitoring, origin: origin))
    }

    private func logAction(for button: AlertButton, on popup: PopupAlertProtocol) {
        switch button {
        case .close, .cancel:
            logger.popup(with: popup, and: .close)
        case .later, .dismiss:
            logger.popup(with: popup, and: .later)
        case .view, .takeAction:
            logger.popup(with: popup, and: .view)
        case .upgrade:
            logger.popup(with: popup, and: .upgrade)
        case .viewDetails:
            logger.popup(with: popup, and: .view)
        }
    }

}
