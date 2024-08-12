import Combine
import CoreSettings
import DesignSystem
import Foundation
import SecurityDashboard
import SwiftTreats
import SwiftUI

class SecurityAlertNotificationProvider: NotificationProvider {
  private let identityDashboardService: IdentityDashboardServiceProtocol
  private let settingsStore: LocalSettingsStore
  @Published
  private var unresolvedAlerts: [UnresolvedAlert] = []
  var trayAlertsSubcription: AnyCancellable?

  init(
    identityDashboardService: IdentityDashboardServiceProtocol,
    settingsStore: LocalSettingsStore
  ) {
    self.settingsStore = settingsStore
    self.identityDashboardService = identityDashboardService
    setup()
  }

  private func setup() {
    self.identityDashboardService
      .trayAlertsPublisher()
      .receive(on: DispatchQueue.main)
      .map { trayAlerts in
        trayAlerts.sorted {
          let date1 = $0.breach.creationDate ?? 0
          let date2 = $1.breach.creationDate ?? 0
          return date1 > date2
        }
        .compactMap(UnresolvedAlert.init)
      }
      .assign(to: &$unresolvedAlerts)
  }

  public func notificationPublisher() -> AnyPublisher<[DashlaneNotification], Never> {
    $unresolvedAlerts
      .map { unresolvedAlerts -> AnyPublisher<[DashlaneNotification], Never> in
        guard !unresolvedAlerts.isEmpty else {
          return Just<[DashlaneNotification]>([]).eraseToAnyPublisher()
        }

        return
          unresolvedAlerts
          .compactMap { [weak self] alert -> AnyPublisher<DashlaneNotification, Never>? in
            self?.publisher(for: alert)
          }
          .combineLatest()
      }
      .switchToLatest()
      .prepend([])
      .eraseToAnyPublisher()
  }

  private func publisher(for unresolvedAlert: UnresolvedAlert) -> AnyPublisher<
    DashlaneNotification, Never
  > {
    let settingsPrefix: String = "security-alert-\(unresolvedAlert.alert.breach.id)"
    let settings = NotificationSettings(
      prefix: settingsPrefix,
      settings: settingsStore)
    let type: SecurityAlertNotification.NotificationType
    switch unresolvedAlert.alert.breach.kind {
    case .default:
      type = .breachAlert
    case .dataLeak:
      type = .darkWebAlert
    }
    let dismissAction: () -> Void = { [identityDashboardService] in
      Task {
        await identityDashboardService.mark(
          breaches: [unresolvedAlert.alert.breach.id], as: .acknowledged)
      }
    }

    return
      settings
      .settingsChangePublisher()
      .map {
        SecurityAlertNotification(
          state: settings.fetchState(),
          creationDate: settings.creationDate,
          notificationActionHandler: settings,
          unresolvedAlert: unresolvedAlert,
          settingsPrefix: settingsPrefix,
          type: type,
          dismissAction: dismissAction)
      }
      .eraseToAnyPublisher()
  }
}

struct SecurityAlertNotification: DashlaneNotification {
  enum NotificationType {
    case darkWebAlert
    case breachAlert
  }

  let state: NotificationCenterService.Notification.State
  let icon: Image
  let title: String
  let description: String
  let category: NotificationCategory = .securityAlerts
  let id: String
  let notificationActionHandler: NotificationActionHandler
  let kind: NotificationCenterService.Notification
  let creationDate: Date
  let type: NotificationType
  let dismissAction: () -> Void

  init(
    state: NotificationCenterService.Notification.State,
    creationDate: Date,
    notificationActionHandler: NotificationActionHandler,
    unresolvedAlert: UnresolvedAlert,
    settingsPrefix: String,
    type: NotificationType,
    dismissAction: @escaping () -> Void
  ) {
    self.dismissAction = dismissAction
    self.state = state
    self.notificationActionHandler = notificationActionHandler
    self.creationDate = creationDate
    self.id = settingsPrefix
    self.kind = .dynamic(.securityAlert(alert: unresolvedAlert))
    self.type = type
    switch type {
    case .breachAlert:
      self.title = L10n.Localizable.securityAlertNotificationTitle
      let domain = unresolvedAlert.alert.breach.domains().first ?? "-"
      self.description = L10n.Localizable.actionItemBreachDetail(domain)
      self.icon = Image.ds.notification.outlined
    case .darkWebAlert:
      self.title = L10n.Localizable.actionItemDarkwebTitle
      self.description = L10n.Localizable.actionItemDarkwebDetail
      self.icon = Image.ds.feature.darkWebMonitoring.outlined
    }
  }
}
