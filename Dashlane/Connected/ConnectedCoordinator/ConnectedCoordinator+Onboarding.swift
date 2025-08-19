import CoreSession
import Foundation
import SwiftTreats
import SwiftUI
import UIComponents

extension ConnectedCoordinator {
  func showBiometricsOrPinOnboarding() {
    let viewModel = sessionServices.makeSSOEnableBiometricsOrPinViewModel()
    let view = SSOEnableBiometricsOrPinView(viewModel: viewModel) { [weak self] in
      self?.finishLaunch()
    }
    let controller = UIHostingController(rootView: view)
    window.rootViewController?.present(controller, animated: true)
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
        self.showConnectedView()
      }
    }

    guard let navigationController = self.window.rootViewController as? UINavigationController
    else {
      assertionFailure()
      self.showConnectedView()
      return
    }
    let view = FastLocalSetupView<FastLocalSetupInLoginViewModel>(model: model)
      .navigationBarBackButtonHidden(true)
    navigationController.setRootNavigation(view)
  }
}
