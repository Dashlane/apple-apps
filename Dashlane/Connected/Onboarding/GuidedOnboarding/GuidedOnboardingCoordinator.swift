import UIKit

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
    private var logService: GuidedOnboardingLogsService

    init(navigator: DashlaneNavigationController? = nil, sessionServices: SessionServicesContainer,
         completion: ((CompletionResult) -> Void)? = nil) {
        self.navigator = navigator ?? DashlaneNavigationController()
        self.navigator.view.backgroundColor = .clear
        self.navigator.modalPresentationStyle = .fullScreen
        self.completion = completion
        self.sessionServices = sessionServices
        self.logService = GuidedOnboardingLogsService(usageLogService: sessionServices.activityReporter.legacyUsage)
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
            self.logService.log(.displayed(question: surveyStep.question))
            navigator.push(makeGuidedOnboardingView(step: surveyStep))
        case .darkWebMonitoringOnboarding:
            startDarkWebMonitoringOnboarding()
        case .creatingPlan:
            self.logService.log(.planScreenShown)
            navigator.setRootNavigation(makeCreatingPlanView())
        }
    }

    private func startDarkWebMonitoringOnboarding() {
        let transitionHandler = GuidedOnboardingTransitionHandler(navigationController: navigator, interactionController: interactionController) { [weak self] in
            self?.completion?(.finished)
        }
        let darkWebMonitoringOnboarding = DWMOnboardingCoordinator(context: .guidedOnboarding, navigator: navigator, transitionHandler: transitionHandler, sessionServices: sessionServices) { [weak self] result in
            switch result {
            case .back:
                self?.navigator.pop(animated: true)
                self?.subcoordinator = nil
            case .skip:
                self?.move(to: .creatingPlan)
                self?.subcoordinator = nil
            case .unexpectedError:
                self?.move(to: .creatingPlan)
                self?.subcoordinator = nil
            }
        }
        subcoordinator = darkWebMonitoringOnboarding
        subcoordinator?.start()
    }

    func makeGuidedOnboardingView(step: GuidedOnboardingSurveyStep) -> GuidedOnboardingView<GuidedOnboardingViewModel> {
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
            }
        })

        return GuidedOnboardingView(viewModel: viewModel)
    }

    func makeCreatingPlanView() -> GuidedOnboardingPlanView {
        return GuidedOnboardingPlanView(transitionHandler: GuidedOnboardingTransitionHandler(navigationController: navigator, interactionController: interactionController) { [weak self] in
            self?.logService.log(.planScreenDismissed)
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
