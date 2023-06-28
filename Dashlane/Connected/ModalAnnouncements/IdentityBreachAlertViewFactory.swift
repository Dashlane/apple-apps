import DesignSystem
import Foundation
import SecurityDashboard
import UIKit

struct IdentityBreachAlertFactory {

    let viewModel: IdentityBreachAlertViewModel

    func alert(for breachesPopup: [PopupAlertProtocol]) -> UIViewController {
        if let popup = breachesPopup.first, breachesPopup.count == 1 {
            return singleBreachAlert(viewModel: viewModel, popup: popup)
        }
        return groupedNotificationsAlert(viewModel: viewModel)
    }

    private func singleBreachAlert(viewModel: IdentityBreachAlertViewModel, popup: PopupAlertProtocol) -> UIAlertController {
        let alertInformation = SecurityBreachAlert.alert(for: popup) { (button) in
            viewModel.handleAction(for: button, on: popup)
        }
        return alertInformation.controller
    }

    private func groupedNotificationsAlert(viewModel: IdentityBreachAlertViewModel) -> UIAlertController {

        let numberOfBreaches = viewModel.breaches.count

        let message = NSMutableAttributedString(string: L10n.Localizable.securityBreachMultipleAlertDescription(numberOfBreaches))

        if let range = message.string.range(of: "\(numberOfBreaches)") {
            message.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.ds.text.brand.standard],
                                  range: NSRange(range, in: message.string))
        }

        let alert = UIAlertController(title: NSLocalizedString("SECURITY_BREACH_MULTIPLE_ALERT_TITLE", comment: ""),
                                      message: "",
                                      preferredStyle: .alert)

        alert.setValue(message, forKey: "attributedMessage")

        let breachesId = viewModel.breaches.map { $0.breach.id }
        let laterAction = UIAlertAction(title: NSLocalizedString("SECURITY_BREACH_MULTIPLE_ALERT_CLOSE_CTA", comment: ""), style: .cancel) { [viewModel] _ in
                        viewModel.updateBreachesStatus(for: breachesId, to: .viewed)
        }
        let viewAction = UIAlertAction(title: NSLocalizedString("SECURITY_BREACH_MULTIPLE_ALERT_VIEW_CTA", comment: ""), style: .default) { [viewModel] _ in
            viewModel.showDarkWebMonitoringSection()
            viewModel.updateBreachesStatus(for: breachesId, to: .viewed)
        }

        alert.addAction(laterAction)
        alert.addAction(viewAction)

        alert.preferredAction = viewAction
        return alert
    }
}
