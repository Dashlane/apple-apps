import UIKit
import UIComponents

class GuidedOnboardingCoordinator: NSObject, Coordinator, SubcoordinatorOwner {

    enum Step {
        case survey(surveyStep: GuidedOnboardingSurveyStep)
        case darkWebMonitoringOnboarding
        case creatingPlan
    }

    enum CompletionResult {
        case finished
    }

    let navigator: DashlaneNavigationController
    var subcoordinator: Coordinator?

    private let guidedOnboardingService: GuidedOnboardingService
    private let dwmOnboardingService: DWMOnboardingService
    private let completion: ((CompletionResult) -> Void)?
    private let sessionServices: SessionServicesContainer
    private let animator = GuidedOnboardingAnimator()
    private let interactionController: UIPercentDrivenInteractiveTransition

    init(navigator: DashlaneNavigationController? = nil, sessionServices: SessionServicesContainer,
         completion: ((CompletionResult) -> Void)? = nil) {
        self.navigator = navigator ?? DashlaneNavigationController()
        self.navigator.view.backgroundColor = .clear
        self.navigator.modalPresentationStyle = .fullScreen
        self.completion = completion
        self.sessionServices = sessionServices
        self.guidedOnboardingService = GuidedOnboardingService(dataProvider: GuidedOnboardingSettingsProvider(userSettings: sessionServices.spiegelUserSettings))
        self.dwmOnboardingService = sessionServices.dwmOnboardingService
        self.interactionController = UIPercentDrivenInteractiveTransition()
    }

    func start() {
        navigator.transitioningDelegate = self
        if let currentStep = guidedOnboardingService.currentStep() {
            move(to: .survey(surveyStep: currentStep))
        } else {
            move(to: .darkWebMonitoringOnboarding)
        }
    }

    private func move(to step: Step) {
        switch step {
        case .survey(let surveyStep):
            navigator.push(makeGuidedOnboardingView(step: surveyStep))
        case .darkWebMonitoringOnboarding:
            navigator.push(makeDarkWebMonitoringOnboardingFlow())
        case .creatingPlan:
            navigator.setRootNavigation(makeCreatingPlanView())
        }
    }

    private func makeDarkWebMonitoringOnboardingFlow() -> DWMOnboardingFlow {
        let transitionHandler = GuidedOnboardingTransitionHandler(
            navigationController: navigator,
            interactionController: interactionController
        ) { [weak self] in
            self?.completion?(.finished)
        }
        let viewModel = sessionServices
            .viewModelFactory
            .makeDWMOnboardingFlowViewModel(transitionHandler: transitionHandler) { [weak self] result in
                switch result {
                case .back:
                    self?.navigator.pop(animated: true)
                case .skip:
                    self?.move(to: .creatingPlan)
                case .unexpectedError:
                    self?.move(to: .creatingPlan)
                }
            }

        return DWMOnboardingFlow(viewModel: viewModel)
    }

    func makeGuidedOnboardingView(step: GuidedOnboardingSurveyStep) -> GuidedOnboardingView {
        let viewModel = sessionServices.viewModelFactory.makeGuidedOnboardingViewModel(guidedOnboardingService: guidedOnboardingService,
                                                                                       step: step,
                                                                                       completion: { [weak self] result in
            switch result {
            case .nextStep(let step):
                if let step = step {
                    self?.move(to: .survey(surveyStep: step))
                } else {
                                        self?.storeGivenAnswers()

                    if self?.dwmOnboardingService.canShowDWMOnboarding == true {
                        self?.move(to: .darkWebMonitoringOnboarding)
                    } else {
                        self?.dwmOnboardingService.dwmOnboardingNotShownInAccountCreation()
                        self?.move(to: .creatingPlan)
                    }
                }
            case .previousStep:
                self?.navigator.pop(animated: true)
            case .skip:
                self?.move(to: .creatingPlan)
            }
        })

        return GuidedOnboardingView(viewModel: viewModel)
    }

    func makeCreatingPlanView() -> GuidedOnboardingPlanView {
        return GuidedOnboardingPlanView(transitionHandler: GuidedOnboardingTransitionHandler(navigationController: navigator, interactionController: interactionController) { [weak self] in
            self?.completion?(.finished)
        })
    }

    private func storeGivenAnswers() {
        guidedOnboardingService.storeGivenAnswers()
    }
}

extension GuidedOnboardingCoordinator: UIViewControllerTransitioningDelegate {

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return animator
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }
}
