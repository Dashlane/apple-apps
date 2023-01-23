import Foundation

protocol GuidedOnboardingDataProvider {
    var storedAnswers: [GuidedOnboardingQuestion: GuidedOnboardingAnswer] { get }
    func storeAnswers(answers: [GuidedOnboardingQuestion: GuidedOnboardingAnswer])
    func removeStoredAnswers()
    func markGuidedOnboardingAsSkipped()
}
