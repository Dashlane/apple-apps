import Foundation

class GuidedOnboardingSurveyStep {

    let question: GuidedOnboardingQuestion
    let answers: [GuidedOnboardingAnswer]
    let nextActionTitle: String

    init(question: GuidedOnboardingQuestion,
         answers: [GuidedOnboardingAnswer],
         nextActionTitle: String = L10n.Localizable.kwCmContinue) {
        self.question = question
        self.answers = answers
        self.nextActionTitle = nextActionTitle
    }
}
