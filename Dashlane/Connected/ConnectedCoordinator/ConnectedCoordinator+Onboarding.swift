import CoreSession
import Foundation
import SwiftTreats
import SwiftUI
import UIComponents

extension ConnectedCoordinator {
  func showOnboarding() {
    let navigator = DashlaneNavigationController()
    let model = sessionServices.makeGuidedOnboardingFlowViewModel(navigator: navigator) {
      [weak self] in
      guard let self else {
        return
      }
      self.window.rootViewController = self.connectedViewController

      if self.onboardingService.shouldShowBiometricsOrPinOnboardingForSSO {
        self.showBiometricsOrPinOnboarding()
      } else {
        self.finishLaunch()
      }
    }

    let sessionServices = sessionServices
    let onboardingView = GuidedOnboardingFlow(model: model)
      .modifier(
        ConnectedEnvironmentViewModifier(model: sessionServices.makeConnectedEnvironmentModel()))
    let backgroundViewController = makeBackgroundViewController()

    navigator.setRootNavigation(onboardingView, barStyle: .hidden(), animated: true)
    self.window.rootViewController = navigator

    navigator.present(backgroundViewController, animated: false) {
      backgroundViewController.dismiss(animated: true) { [weak self] in
        guard let self else {
          return
        }
        self.window.rootViewController = UIViewController()
        self.window.rootViewController?.view.backgroundColor = .ds.background.default
        self.window.rootViewController?.present(navigator, animated: false) {

        }
      }
    }
  }
}

extension ConnectedCoordinator {
  func showBiometricsOrPinOnboarding() {
    let viewModel = sessionServices.makeSSOEnableBiometricsOrPinViewModel()
    let view = SSOEnableBiometricsOrPinView(viewModel: viewModel) { [weak self] in
      self?.finishLaunch()
    }
    let controller = UIHostingController(rootView: view)
    connectedViewController.present(controller, animated: true)
  }

  func showFastLocalSetupForRememberMasterPassword() {
    showFastLocalSetup(for: nil)
  }

  func showFastLocalSetup(for biometry: Biometry?) {
    let model = sessionServices.viewModelFactory.makeFastLocalSetupInLoginViewModel(
      masterPassword: sessionServices.session.authenticationMethod.userMasterPassword,
      biometry: biometry
    ) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .next:
        self.transitionToConnectedViewController()
      }
    }

    guard let navigationController = self.window.rootViewController as? DashlaneNavigationController
    else {
      assertionFailure()
      self.transitionToConnectedViewController()
      return
    }
    let view = FastLocalSetupView<FastLocalSetupInLoginViewModel>(model: model)
      .navigationBarBackButtonHidden(true)
    navigationController.setRootNavigation(view)
  }
}
