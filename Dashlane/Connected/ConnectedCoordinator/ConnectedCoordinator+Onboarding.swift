import Foundation
import DashlaneAppKit
import SwiftTreats
import SwiftUI
import UIComponents

extension ConnectedCoordinator {
    func showOnboarding() {
        let backgroundViewController = makeBackgroundViewController()

        let guidedOnboardingCoordinator = GuidedOnboardingCoordinator(sessionServices: sessionServices) { [weak self] result in
            guard let self = self else {
                return
            }

            switch result {
            case .finished:
                if self.onboardingService.shouldShowBiometricsOrPinOnboardingForSSO {
                    self.showBiometricsOrPinOnboarding()
                } else {
                    self.finishLaunch()
                    self.subcoordinator = nil
                }
            }
        }

        guidedOnboardingCoordinator.start()
        let guidedOnboardingNavigator = guidedOnboardingCoordinator.navigator

        self.window.rootViewController = guidedOnboardingNavigator

        guidedOnboardingNavigator.present(backgroundViewController, animated: false) {
            backgroundViewController.dismiss(animated: true) {
                self.window.rootViewController = self.splitViewController
                self.splitViewController.present(guidedOnboardingNavigator, animated: false) {
                    self.configure(self.splitViewController)
                }
            }
        }

        subcoordinator = guidedOnboardingCoordinator
    }
}

extension ConnectedCoordinator {
    func showBiometricsOrPinOnboarding() {
        let viewModel = sessionServices.makeSSOEnableBiometricsOrPinViewModel()
        let view = SSOEnableBiometricsOrPinView(viewModel: viewModel) { [weak self] in
            self?.finishLaunch()
        }
        let controller = UIHostingController(rootView: view)
        splitViewController.present(controller, animated: true)
    }

    func showFastLocalSetupForRememberMasterPassword() {
        showFastLocalSetup(for: nil)
    }

    func showFastLocalSetup(for biometry: Biometry?) {
        let model = sessionServices.viewModelFactory.makeFastLocalSetupInLoginViewModel(masterPassword: sessionServices.session.authenticationMethod.userMasterPassword, biometry: biometry) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .next:
                self.transitionToSplitViewController()
            }
        }

        guard let navigationController = self.window.rootViewController as? DashlaneNavigationController else {
            assertionFailure()
            self.transitionToSplitViewController()
            return
        }
        let view = FastLocalSetupView<FastLocalSetupInLoginViewModel>(model: model)
            .navigationBarBackButtonHidden(true)
        navigationController.setRootNavigation(view)
    }
}

#if targetEnvironment(macCatalyst)
extension ConnectedCoordinator {
    func showBrowsersExtensionOnboarding() {
        let viewModel = BrowsersExtensionsOnboardingViewModel(appKitBridge: sessionServices.appServices.appKitBridge,
                                                              featureService: sessionServices.featureService,
                                                              sessionDirectory: sessionServices.session.directory) { [weak self] in
            guard let self = self else { return }
            self.onboardingService.didSeeBrowsersExtensionsOnboarding()
            self.transitionToSplitViewController()
        }
        guard let navigationController = self.window.rootViewController as? DashlaneNavigationController else {
            assertionFailure()
            self.transitionToSplitViewController()
            return
        }
        let transparent = NavigationBarStyle.transparent(tintColor: .clear, statusBarStyle: .default)
        navigationController.setRootNavigation(BrowsersExtensionsOnboardingView(viewModel: viewModel), barStyle: transparent, animated: true)
    }

}
#endif
