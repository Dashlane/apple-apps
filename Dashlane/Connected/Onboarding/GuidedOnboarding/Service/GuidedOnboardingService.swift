import Foundation

struct GuidedOnboardingSelectedAnswer: Equatable, Hashable {
    let question: GuidedOnboardingQuestion
    let answer: GuidedOnboardingAnswer

    static func == (lhs: GuidedOnboardingSelectedAnswer, rhs: GuidedOnboardingSelectedAnswer) -> Bool {
        lhs.question == rhs.question && lhs.answer == rhs.answer
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(question)
        hasher.combine(answer)
    }
}

class GuidedOnboardingService {

    let steps: [GuidedOnboardingSurveyStep]
    private let dataProvider: GuidedOnboardingDataProvider
    private var answers: [GuidedOnboardingQuestion: GuidedOnboardingAnswer] = [:]

    var atLeastOneQuestionHasBeenAnswered: Bool {
        return !answers.isEmpty
    }

    init(dataProvider: GuidedOnboardingDataProvider) {
        self.dataProvider = dataProvider
        self.steps = [ GuidedOnboardingSurveyStep(question: .whyDashlane,
                                                  answers: [ .autofill,
                                                             .syncAcrossDevices,
                                                             .warnMeAboutHacks ]),
                       GuidedOnboardingSurveyStep(question: .howPasswordsHandled,
                                                  answers: [ .memorizePasswords,
                                                             .browser,
                                                             .somethingElse ])
        ]
        self.answers = dataProvider.storedAnswers
    }

    func currentStep() -> GuidedOnboardingSurveyStep? {
        let allQuestions = Set(steps.map({ $0.question }))
        let answeredQuestions = Set(answers.keys)
        let unansweredQuestions = Array(allQuestions.subtracting(answeredQuestions))
        return steps
            .filter({ unansweredQuestions.contains($0.question) })
            .sorted(by: { (stepA, stepB) -> Bool in
                return stepA.question.rawValue < stepB.question.rawValue
            })
            .first
    }

    func selectAnswer(_ answer: GuidedOnboardingAnswer?, forQuestion question: GuidedOnboardingQuestion) {
        answers[question] = answer
    }

    func selectedAnswer(forQuestion question: GuidedOnboardingQuestion) -> GuidedOnboardingAnswer? {
        return answers[question]
    }

    func storeGivenAnswers() {
        dataProvider.storeAnswers(answers: answers)
    }
}
