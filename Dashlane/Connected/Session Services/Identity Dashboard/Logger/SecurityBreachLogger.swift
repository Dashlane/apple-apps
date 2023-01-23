import Foundation
import SecurityDashboard
import DashlaneReportKit

struct SecurityBreachLogger {
    let usageLogService: UsageLogServiceProtocol

        enum PopupAction {
        case ok
        case close
        case later
        case view
        case show
        case upgrade
        case upgradePremiumPlus
        case viewDetails

        var action: UsageLogCode126SecurityAndDarkWebAlertsAndAnnouncements.ActionType {
            switch self {
                case .ok: return .ok
                case .close: return .close
                case .later: return .later
                case .view: return .view
                case .show: return .show
                case .upgrade: return .upgrade
                case .upgradePremiumPlus: return .premiumPlusUpgrade
                case .viewDetails: return .view
            }
        }
    }

    func popup(with popupAlert: PopupAlertProtocol, and action: PopupAction) {
        let log126 = UsageLogCode126SecurityAndDarkWebAlertsAndAnnouncements(type: .popUp,
                                                                             type_sub: popupAlert.typeSub,
                                                                             action: action.action,
                                                                             alert_id: popupAlert.breach.kind == .default ? popupAlert.breach.id : nil,
                                                                             similar_credentials_count: popupAlert.breach.kind == .default ? popupAlert.data.impactedCredentials.count : nil)
        usageLogService.post(log126)
    }

        enum GroupedPopupAction {
        case close
        case view
        case show

        var action: UsageLogCode126SecurityAndDarkWebAlertsAndAnnouncements.ActionType {
            switch self {
                case .close: return .close
                case .view: return .view
                case .show: return .show
            }
        }
    }

    func groupedPopup(with numberOfAlerts: Int, and action: GroupedPopupAction) {
        let log126 = UsageLogCode126SecurityAndDarkWebAlertsAndAnnouncements(type: .popUpMulti,
                                                                             type_sub: .security,
                                                                             action: action.action,
                                                                             action_sub: "\(numberOfAlerts)")
        usageLogService.post(log126)
    }

        enum IssuesNotificationAction {
        case show
        case view

        var action: UsageLogCode126SecurityAndDarkWebAlertsAndAnnouncements.ActionType {
            switch self {
                case .show: return .show
                case .view: return .view
            }
        }
    }

    func issuesNotification(with popupAlert: PopupAlertProtocol, and action: IssuesNotificationAction) {
        let log126 = UsageLogCode126SecurityAndDarkWebAlertsAndAnnouncements(type: .tabOverview,
                                                                             action: action.action)
        usageLogService.post(log126)
    }

        func unresolvedAlertsShow() {
        let log126 = UsageLogCode126SecurityAndDarkWebAlertsAndAnnouncements(type: .feedAlert,
                                                                             type_sub: .security,
                                                                             action: .show)
        usageLogService.post(log126)
    }

        enum TrayAction {
        case close
        case view
        case show
        case upgrade
        case reveal
        case hide

        var action: UsageLogCode126SecurityAndDarkWebAlertsAndAnnouncements.ActionType {
            switch self {
                case .close: return .close
                case .view: return .view
                case .show: return .show
                case .upgrade: return .upgrade
                case .reveal: return .reveal
                case .hide: return .hide
            }
        }
    }

    enum TrayPosition: Int {
        case top
        case below

        init(index: Int) {
            switch index {
                case 0: self = .top
                default: self = .below
            }
        }
    }

    func tray(with popupAlert: TrayAlertProtocol, action: TrayAction, position: TrayPosition) {
        let log126 = UsageLogCode126SecurityAndDarkWebAlertsAndAnnouncements(type: .identityDashboard,
                                                                             type_sub: popupAlert.typeSub,
                                                                             action: action.action,
                                                                             action_sub: "\(position)",
            alert_id: popupAlert.breach.kind == .default ? popupAlert.breach.id : nil,
            similar_credentials_count: popupAlert.breach.kind == .default ? popupAlert.data.impactedCredentials.count : nil)
        usageLogService.post(log126)
    }
}

private extension AlertProtocol {
    var typeSub: UsageLogCode126SecurityAndDarkWebAlertsAndAnnouncements.Type_subType {
        if self.breach.kind != .dataLeak {
            return .security
        }

        if (self.breach.domains ?? []).isEmpty {
            if self.data.impactedCredentials.isEmpty {
                return .darkWebNodomainnomatch
            } else {
                return .darkWebNodomain
            }
        }

        if self.breach.leaksPassword && !self.breach.containsPII {
                        return .darkWebPassword
        } else if !self.breach.leaksPassword && self.breach.containsPII {
                        return .darkWebPiis
        } else {
                        return .darkWebPasswordPiis
        }
    }
}

extension UsageLogServiceProtocol {
    var securityBreach: SecurityBreachLogger {
        return SecurityBreachLogger(usageLogService: self)
    }
}
