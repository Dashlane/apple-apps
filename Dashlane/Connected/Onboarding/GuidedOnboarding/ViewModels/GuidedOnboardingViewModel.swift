import SwiftUI
import DashTypes

enum GuidedOnboardingViewModelCompletion {
    case nextStep(GuidedOnboardingSurveyStep?)
    case previousStep
}

protocol GuidedOnboardingViewModelProtocol: ObservableObject {
    var onboardingFAQService: OnboardingFAQService { get }
    var step: GuidedOnboardingSurveyStep { get }
    var answers: [GuidedOnboardingAnswerViewModel] { get }
    var hasSelectedAnswer: Bool { get set }
    var showNextButton: Bool { get set }
    var showAltActionButton: Bool { get set }
    var altActionTitle: String { get set }
    var canGoBackToPreviousQuestion: Bool { get }
    var selectedAnswer: GuidedOnboardingAnswer? { get }
    var stepNumberingDetails: (totalSteps: Int, currentStepIndex: Int)? { get }

    func selectAnswer(_ answer: GuidedOnboardingAnswer?)
    func goToNextStep()
    func goToPreviousStep()
    func faqSectionShown()
    func faqQuestionSelected(_ question: OnboardingFAQ)
}

class GuidedOnboardingViewModel: GuidedOnboardingViewModelProtocol, SessionServicesInjecting {
    private let guidedOnboardingService: GuidedOnboardingService
    private let dwmOnboardingService: DWMOnboardingService
    let onboardingFAQService = OnboardingFAQService()
    private let completion: ((GuidedOnboardingViewModelCompletion) -> Void)?
    let step: GuidedOnboardingSurveyStep
    let answers: [GuidedOnboardingAnswerViewModel]
    let logService: GuidedOnboardingLogsService

    @Published
    var hasSelectedAnswer: Bool = false
    @Published
    var showNextButton: Bool = false
    @Published
    var showAltActionButton: Bool = false
    @Published
    var altActionTitle: String = ""

    var canGoBackToPreviousQuestion: Bool {
        guidedOnboardingService.atLeastOneQuestionHasBeenAnswered
    }

    var selectedAnswer: GuidedOnboardingAnswer? {
        guidedOnboardingService.selectedAnswer(forQuestion: step.question)
    }

    var stepNumberingDetails: (totalSteps: Int, currentStepIndex: Int)? {
        let totalSteps = guidedOnboardingService.steps.count
        guard let currentStepIndex = (guidedOnboardingService.steps.firstIndex { $0.question == self.step.question }) else {
            assertionFailure("The current step is not found in the steps collection in the service. It should never happen.")
            return nil
        }

                let correctedStepIndex = Int(currentStepIndex) + 1

                let correctedTotalSteps = dwmOnboardingService.canShowDWMOnboarding ? (totalSteps + 1) : totalSteps

        return (totalSteps: correctedTotalSteps, currentStepIndex: correctedStepIndex)
    }

    init(guidedOnboardingService: GuidedOnboardingService,
         dwmOnboardingService: DWMOnboardingService,
         step: GuidedOnboardingSurveyStep,
         logService: UsageLogServiceProtocol,
         completion: ((GuidedOnboardingViewModelCompletion) -> Void)?) {
        self.guidedOnboardingService = guidedOnboardingService
        self.dwmOnboardingService = dwmOnboardingService
        self.step = step
        self.logService = logService.guidedOnboardingLogsService
        self.completion = completion
        self.answers = step.answers.map { GuidedOnboardingAnswerViewModel(content: $0) }
    }

    func selectAnswer(_ answer: GuidedOnboardingAnswer?) {
        if let answer = answer {
            logService.log(.selected(answer: answer))
        }

        guidedOnboardingService.selectAnswer(answer, forQuestion: step.question)
    }

    func goToNextStep() {
        if let answer = selectedAnswer {
            logService.log(.continueAfterSelectingAnswer(answer: answer, question: step.question))
        }

        completion?(.nextStep(guidedOnboardingService.currentStep()))
    }

    func goToPreviousStep() {
        completion?(.previousStep)
    }

    func faqSectionShown() {
        logService.log(.faqSectionDisplayed)
    }

    func faqQuestionSelected(_ question: OnboardingFAQ) {
        logService.log(.faqItemSelected(item: question))
    }
}
