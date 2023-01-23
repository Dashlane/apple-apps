import UIKit
import CoreSession
import SwiftUI
import Combine
import DashTypes
import DashlaneAppKit
import SwiftTreats

class PreAccountCreationOnboardingCoordinator: Coordinator {

    let navigator: DashlaneNavigationController
    let appServices: AppServicesContainer
    let completion: (PreAccountCreationOnboardingViewModel.NextStep) -> Void

    private var subscriptions = Set<AnyCancellable>()

    init(navigator: DashlaneNavigationController,
         appServices: AppServicesContainer,
         completion: @escaping (PreAccountCreationOnboardingViewModel.NextStep) -> Void) {
        self.navigator = navigator
        self.appServices = appServices
        self.completion = completion
    }

    func start() {
        displayOnboarding()
        showVersionValidityAlertIfNeeded()
    }

    private func displayOnboarding() {
        if let viewController = navigator.viewControllers.first as? PreAccountCreationOnboardingController {
            navigator.popToRootViewController(animated: true)
            viewController.viewModel.completion = { [weak self] nextStep in
                self?.completion(nextStep)
            }
        } else {
            let isIpad = Device.isIpadOrMac
            let storyboard = isIpad
                ? StoryboardScene.PreAccountCreationOnboardingiPad.storyboard
                : StoryboardScene.PreAccountCreationOnboarding.storyboard
            guard let onboardingVC = storyboard.instantiateViewController(identifier: String(describing: PreAccountCreationOnboardingController.self)) as? PreAccountCreationOnboardingController else { return }
            onboardingVC.viewModel = PreAccountCreationOnboardingViewModel(installerLogService: appServices.installerLogService,
                                                                           localDataRemover: appServices.makeLocalDataRemover())
            onboardingVC.viewModel.completion = { [weak self] nextStep in
                self?.completion(nextStep)
            }
            navigator.setViewControllers([onboardingVC], animated: true)
        }
        appServices.activityReporter.reportPageShown(.onboardingTrustScreens)
    }
}

private extension PreAccountCreationOnboardingCoordinator {
    private func showVersionValidityAlertIfNeeded() {
        appServices.versionValidityService.shouldShowAlertPublisher().receive(on: DispatchQueue.main).sink { [weak self] status in
            guard let self = self else { return }
            let alertDismissed = { self.appServices.versionValidityService.messageDismissed(for: status) }
            guard let alert = VersionValidityAlert(status: status, alertDismissed: alertDismissed).makeAlert() else {
                return
            }

            self.navigator.present(alert, animated: true)
            self.appServices.versionValidityService.messageShown(for: status)
        }.store(in: &subscriptions)
    }
}
