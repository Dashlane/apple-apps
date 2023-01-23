import Foundation

class GuidedOnboardingInMemoryProvider: GuidedOnboardingDataProvider {
    var hasSeenGuidedOnboarding: Bool = false

    var hasSkippedGuidedOnboarding: Bool = false

    var storedAnswers: [GuidedOnboardingQuestion: GuidedOnboardingAnswer] = [:]

    func storeAnswers(answers: [GuidedOnboardingQuestion: GuidedOnboardingAnswer]) {
        storedAnswers = answers
    }

    func removeStoredAnswers() {
        storedAnswers = [:]
    }

    func markGuidedOnboardingAsSkipped() {
            }
}
