import Foundation
import AuthenticationServices
import UIKit

class CredentialProviderConfigurationViewController: UIViewController, InjectableViewController {
    @IBOutlet weak var settingsBubbleView: UIView!
    
    struct Input {
        let completion: () -> Void
    }

    var input: Input!

    override func viewDidLoad() {
        if view.traitCollection.userInterfaceStyle != .dark {
            setupShadow()
        }
    }
    
    
    @IBAction func ctaTapped(_ sender: Any) {
        input.completion()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            switch traitCollection.userInterfaceStyle {
            case .dark:
                removeShadow()
            case .light, .unspecified:
                setupShadow()
            @unknown default:
                setupShadow()
            }
        }
    }
    
    private func setupShadow() {
        settingsBubbleView.layer.shadowOffset = CGSize(width: 0, height: 1)
        settingsBubbleView.layer.shadowColor = UIColor(red:0, green:0, blue:0, alpha:0.15).cgColor
        settingsBubbleView.layer.shadowOpacity = 1
        settingsBubbleView.layer.shadowRadius = 10
    }
    
    private func removeShadow() {
        settingsBubbleView.layer.shadowOpacity = 0
    }
}

