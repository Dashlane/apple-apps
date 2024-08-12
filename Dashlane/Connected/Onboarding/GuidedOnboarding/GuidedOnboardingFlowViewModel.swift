import CoreSettings
import CoreUserTracking
import LoginKit
import SwiftUI
import UIComponents
import UIDelight
import UIKit

class GuidedOnboardingFlowViewModel: ObservableObject, SessionServicesInjecting {
  private let completion: (() -> Void)
  private let sessionServices: SessionServicesContainer
  private let guidedOnboardingService: GuidedOnboardingService
  private let dwmOnboardingService: DWMOnboardingService
  private let interactionController: UIPercentDrivenInteractiveTransition
  private let transitionDelegate: GuidedOnboardingFlowTransitioningDelegate
  let navigator: DashlaneNavigationController

  enum Step {
    case introQuestion
    case survey(surveyStep: GuidedOnboardingSurveyStep)
    case darkWebMonitoringOnboarding
    case creatingPlan
  }

  @Published
  var steps: [Step] = [.introQuestion]

  public init(
    navigator: DashlaneNavigationController? = nil,
    sessionServices: SessionServicesContainer,
    completion: @escaping (() -> Void)
  ) {
    self.completion = completion
    self.sessionServices = sessionServices
    self.guidedOnboardingService = GuidedOnboardingService(
      dataProvider: GuidedOnboardingSettingsProvider(
        userSettings: sessionServices.spiegelUserSettings))
    self.dwmOnboardingService = sessionServices.dwmOnboardingService

    self.interactionController = UIPercentDrivenInteractiveTransition()
    self.transitionDelegate = GuidedOnboardingFlowTransitioningDelegate(
      interactionController: interactionController)

    self.navigator = navigator ?? DashlaneNavigationController()
    self.navigator.view.backgroundColor = .clear
    self.navigator.modalPresentationStyle = .fullScreen
    self.navigator.transitioningDelegate = transitionDelegate
  }

  func introQuestionAnswered(_ choice: AccountCreationSurveyView.Choice) {
    sessionServices.activityReporter.report(
      UserEvent.SubmitInProductFormAnswer(
        answerList: [.neverUsedBefore, .familiarWithDashlane, .usedAnotherPasswordManager],
        chosenAnswerList: [choice.reportedAnswer()],
        formName: .familiarityWithDashlane))
    switch choice {
    case .neverUsedPWM, .alreadyUsedPWM:
      if let currentStep = guidedOnboardingService.currentStep() {
        steps.append(.survey(surveyStep: currentStep))
        return
      }
    case .knowDashlane:
      sessionServices.dwmOnboardingSettings[.hasGoneStraightToDWMOnboarding] = true
    }

    self.steps.append(.darkWebMonitoringOnboarding)
  }

  func makeGuidedOnboardingView(step: GuidedOnboardingSurveyStep) -> GuidedOnboardingView {
    let viewModel = sessionServices.viewModelFactory.makeGuidedOnboardingViewModel(
      guidedOnboardingService: guidedOnboardingService,
      step: step,
      completion: { [weak self] result in
        switch result {
        case .nextStep(let step):
          if let step = step {
            self?.steps.append(.survey(surveyStep: step))
          } else {
            self?.guidedOnboardingService.storeGivenAnswers()

            if self?.dwmOnboardingService.canShowDWMOnboarding == true {
              self?.steps.append(.darkWebMonitoringOnboarding)
            } else {
              self?.dwmOnboardingService.dwmOnboardingNotShownInAccountCreation()
              self?.steps = [.creatingPlan]
            }
          }
        case .previousStep:
          self?.removeLastStep()

        case .skip:
          self?.steps = [.creatingPlan]
        }
      })

    return GuidedOnboardingView(viewModel: viewModel)
  }

  @MainActor func makeDarkWebMonitoringOnboardingFlow() -> DWMOnboardingFlow {
    let transitionHandler = GuidedOnboardingTransitionHandler(
      navigationController: navigator,
      interactionController: interactionController
    ) { [weak self] in self?.completion() }

    let viewModel = sessionServices
      .viewModelFactory
      .makeDWMOnboardingFlowViewModel(transitionHandler: transitionHandler) { [weak self] result in
        switch result {
        case .back:
          self?.steps.removeLast()
        case .skip, .unexpectedError:
          self?.steps = [.creatingPlan]
        }
      }

    return DWMOnboardingFlow(viewModel: viewModel)
  }

  func makeCreatingPlanView() -> GuidedOnboardingPlanView {
    let transitionHandler = GuidedOnboardingTransitionHandler(
      navigationController: navigator,
      interactionController: interactionController
    ) { [weak self] in
      self?.completion()
    }
    return GuidedOnboardingPlanView(transitionHandler: transitionHandler)
  }

  private func removeLastStep() {
    guard let lastStep = steps.last else {
      return
    }

    switch lastStep {
    case .survey(let step):
      guidedOnboardingService.clearAnswers(of: step.question)
    default:
      break
    }

    steps.removeLast()
  }
}

class GuidedOnboardingFlowTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
  private let animator = GuidedOnboardingAnimator()
  private let interactionController: UIPercentDrivenInteractiveTransition

  init(interactionController: UIPercentDrivenInteractiveTransition) {
    self.interactionController = interactionController
  }

  func animationController(forDismissed dismissed: UIViewController)
    -> UIViewControllerAnimatedTransitioning?
  {
    return animator
  }

  func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning)
    -> UIViewControllerInteractiveTransitioning?
  {
    return interactionController
  }
}

extension AccountCreationSurveyView.Choice {
  fileprivate func reportedAnswer() -> Definition.PossibleFormAnswers {
    switch self {
    case .neverUsedPWM:
      return .neverUsedBefore
    case .alreadyUsedPWM:
      return .usedAnotherPasswordManager
    case .knowDashlane:
      return .familiarWithDashlane
    }
  }
}
