import Foundation

extension UserEvent {

public struct `CompleteOnboardingTask`: Encodable, UserEventProtocol {
public static let isPriority = false
public init(`onboardingTask`: Definition.OnboardingTask) {
self.onboardingTask = onboardingTask
}
public let name = "complete_onboarding_task"
public let onboardingTask: Definition.OnboardingTask
}
}
