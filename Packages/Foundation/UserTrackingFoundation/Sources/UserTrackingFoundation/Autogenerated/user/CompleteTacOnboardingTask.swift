import Foundation

extension UserEvent {

  public struct `CompleteTacOnboardingTask`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(`onboardingTask`: Definition.OnboardingTask) {
      self.onboardingTask = onboardingTask
    }
    public let name = "complete_tac_onboarding_task"
    public let onboardingTask: Definition.OnboardingTask
  }
}
