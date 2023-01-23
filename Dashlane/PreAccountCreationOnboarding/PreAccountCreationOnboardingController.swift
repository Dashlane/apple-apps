import Foundation
import UIKit
import Combine
import DashTypes
import DesignSystem

@objc final class PreAccountCreationOnboardingController: UIViewController {

        @objc static func instantiate() -> PreAccountCreationOnboardingController {
        let storyboard = StoryboardScene.PreAccountCreationOnboarding.storyboard
        guard let controller = storyboard.instantiateViewController(withIdentifier: "PreAccountCreationOnboardingController") as? PreAccountCreationOnboardingController else {
            fatalError("Unable to instatiate PreAccountCreationOnboardingContentViewController")
        }
        return controller
    }

        @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var analyticsInfoButton: UIButton!

        var viewModel: PreAccountCreationOnboardingViewModel!

        private weak var embeddedPageViewController: PreAccountCreationOnboardingPageVC! {
        didSet {
            embeddedPageViewController.pageControl = pageControl
        }
    }

        override func viewDidLoad() {
        super.viewDidLoad()
        applyStyle()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dashlaneNavigationController?.setNavigationBarHidden(true, animated: animated)

        if LocalDataRemover.shouldDeleteLocalData {
            self.presentLocalDataDeletionAlert()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.logger.displayed(screen: .landingScreen)
        analyticsInfoButton.isHidden = BuildEnvironment.current == .appstore
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let pvc = segue.destination as? PreAccountCreationOnboardingPageVC {
            embeddedPageViewController = pvc
            pvc.viewModel = viewModel
        }
    }

        override var prefersStatusBarHidden: Bool {
        return false
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    @IBAction func didTapAccountCreation(_ sender: Any) {
        self.viewModel.showAccountCreation()
    }

    @IBAction func didTapLogin(_ sender: Any) {
        self.viewModel.showLogin()
    }

    @IBAction func presentQAInfo(_ sender: Any) {
        let installationId = self.viewModel.analyticsInstallationId.uuidString
        let alert = UIAlertController(title: "Analytics Installation Id", message: installationId,
                                      preferredStyle: .actionSheet)
        let copyAction = UIAlertAction(title: "Copy", style: .default) { _ in
            UIPasteboard.general.string = installationId
        }
        alert.addAction(copyAction)
        alert.addAction(.init(title: "Cancel", style: .destructive, handler: nil))
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.maxX, y: self.view.bounds.minY, width: 0, height: 0)
        self.present(alert, animated: true, completion: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dashlaneNavigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func presentLocalDataDeletionAlert() {
        let alert = UIAlertController(title: L10n.Localizable.deleteLocalDataAlertTitle,
                                      message: L10n.Localizable.deleteLocalDataAlertMessage,
                                      preferredStyle: .alert)
        let cancel = UIAlertAction(title: L10n.Localizable.cancel, style: .cancel) { [weak self] _ in
            self?.viewModel.disableShouldDeleteLocalDataSetting()
        }
        let deleteDataAction = UIAlertAction(title: L10n.Localizable.deleteLocalDataAlertDeleteCta, style: .destructive) { [weak self] _ in
            self?.viewModel.deleteAllLocalData()
        }
        alert.addAction(deleteDataAction)

        alert.addAction(cancel)
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.maxX, y: self.view.bounds.minY, width: 0, height: 0)
        self.present(alert, animated: true, completion: nil)
    }
}

private extension PreAccountCreationOnboardingController {
    func applyStyle() {
        view.backgroundColor = .ds.background.default

        createAccountButton.backgroundColor = FiberAsset.midGreen.color
        createAccountButton.titleLabel?.font = UIFont.systemFont(ofSize: 17.0)
        createAccountButton.setTitleColor(.white, for: .normal)

        loginButton.setTitleColor(FiberAsset.accentColor.color, for: .normal)
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 17.0)
        pageControl.pageIndicatorTintColor = FiberAsset.pageControl.color
        pageControl.currentPageIndicatorTintColor = FiberAsset.pageControlSelected.color
    }
}
