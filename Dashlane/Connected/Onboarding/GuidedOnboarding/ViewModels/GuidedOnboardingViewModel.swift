import DashTypes
import SwiftUI

enum GuidedOnboardingViewModelCompletion {
  case nextStep(GuidedOnboardingSurveyStep?)
  case previousStep
  case skip
}

class GuidedOnboardingViewModel: ObservableObject, SessionServicesInjecting {

  let step: GuidedOnboardingSurveyStep
  let answers: [GuidedOnboardingAnswer]
  let onboardingFAQService = OnboardingFAQService()
  private let guidedOnboardingService: GuidedOnboardingService
  private let dwmOnboardingService: DWMOnboardingService
  private let completion: ((GuidedOnboardingViewModelCompletion) -> Void)?

  @Published
  var selectedAnswer: GuidedOnboardingAnswer?

  var canGoBackToPreviousQuestion: Bool {
    guidedOnboardingService.atLeastOneQuestionHasBeenAnswered && !isFirstStep
  }

  var isFirstStep: Bool {
    (stepNumberingDetails?.currentStepIndex ?? 0) < 2
  }

  var stepNumberingDetails: (totalSteps: Int, currentStepIndex: Int)? {
    let totalSteps = guidedOnboardingService.steps.count
    guard
      let currentStepIndex =
        (guidedOnboardingService.steps.firstIndex { $0.question == self.step.question })
    else {
      assertionFailure(
        "The current step is not found in the steps collection in the service. It should never happen."
      )
      return nil
    }

    let correctedStepIndex = Int(currentStepIndex) + 1

    let correctedTotalSteps =
      dwmOnboardingService.canShowDWMOnboarding ? (totalSteps + 1) : totalSteps

    return (totalSteps: correctedTotalSteps, currentStepIndex: correctedStepIndex)
  }

  init(
    guidedOnboardingService: GuidedOnboardingService,
    dwmOnboardingService: DWMOnboardingService,
    step: GuidedOnboardingSurveyStep,
    completion: ((GuidedOnboardingViewModelCompletion) -> Void)?
  ) {
    self.guidedOnboardingService = guidedOnboardingService
    self.dwmOnboardingService = dwmOnboardingService
    self.step = step
    self.completion = completion
    self.answers = step.answers
  }

  func selectAnswer(_ answer: GuidedOnboardingAnswer?) {
    selectedAnswer = answer
    guidedOnboardingService.selectAnswer(answer, forQuestion: step.question)
  }

  func goToNextStep() {
    completion?(.nextStep(guidedOnboardingService.currentStep()))
  }

  func goToPreviousStep() {
    completion?(.previousStep)
  }

  func skip() {
    completion?(.skip)
  }
}
