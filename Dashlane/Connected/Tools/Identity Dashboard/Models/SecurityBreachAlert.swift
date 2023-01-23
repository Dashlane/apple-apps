import Foundation
import SecurityDashboard
import CoreCategorizer
import DesignSystem
import UIKit

typealias SecurityBreachAlertHandler = (_ action: AlertButton) -> Void

struct SecurityBreachAlert {

    static func alert(for popupAlert: PopupAlertProtocol,
                      withCompletion completion: @escaping SecurityBreachAlertHandler) -> (controller: UIAlertController, popupAlert: PopupAlertProtocol) {

        let popup = PopupAlert(popupAlert)

		let alert = BreachAlertController(title: popup.title, message: "", preferredStyle: .alert)

        alert.setValue(popup.message, forKey: "attributedMessage")

        let buttons = popupAlert.buttons.left + popupAlert.buttons.right
        let lastButton = buttons.last
        let defaultButtonStyle = UIAlertAction.Style.default
        let lastButtonStyle = UIAlertAction.Style.destructive

        buttons.forEach { button in
            let style = button == lastButton ? lastButtonStyle : defaultButtonStyle
            alert.addAction(UIAlertAction(title: button.localized, style: style, handler: { _ in
                completion(button)
            }))
        }

        alert.preferredAction = alert.actions.last

		return (alert, popupAlert)
	}
}

extension Breach.LeakedData {
	var localizationKey: String {
		switch self {
		case .email: return "SECURITY_BREACH_LEAKED_EMAIL"
		case .username: return "SECURITY_BREACH_LEAKED_USERNAME"
		case .address: return "SECURITY_BREACH_LEAKED_ADDRESS"
		case .password: return "SECURITY_BREACH_LEAKED_PASSWORD"
		case .ssn: return "SECURITY_BREACH_LEAKED_SSN"
		default: return "SECURITY_BREACH_LEAKED_LOGIN"
		}
	}
}

extension AlertButton {
    var localized: String {
        switch self {
        case .cancel:
            return IdentityDashboardLocalizationProvider().localizedString(for: .popupCancelCTA)
        case .close:
            return IdentityDashboardLocalizationProvider().localizedString(for: .popupCloseCTA)
        case .later:
            return IdentityDashboardLocalizationProvider().localizedString(for: .popupLaterCTA)
        case .view:
            return IdentityDashboardLocalizationProvider().localizedString(for: .popupViewCTA)
        case .upgrade:
            return IdentityDashboardLocalizationProvider().localizedString(for: .popupUpgradeCTA)
        case .takeAction:
            return IdentityDashboardLocalizationProvider().localizedString(for: .popupTakeActionCTA)
        case .dismiss:
            return IdentityDashboardLocalizationProvider().localizedString(for: .popupDismissCTA)
        case .viewDetails:
            return IdentityDashboardLocalizationProvider().localizedString(for: .popupViewDetailsCTA)
        }
    }
}

private class BreachAlertController: UIAlertController {
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
        self.view.tintColor = .ds.text.neutral.standard
	}
}
