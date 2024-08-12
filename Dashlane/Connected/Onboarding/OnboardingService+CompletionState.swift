import Foundation

extension OnboardingService {
  enum CompletionState {
    case completed
    case todo
  }

  func completionState(for action: OnboardingChecklistAction) -> CompletionState {
    switch action {
    case .addFirstPasswordsManually:
      return hasPassedPasswordOnboarding ? .completed : .todo
    case .importFromBrowser:
      return hasPassedPasswordOnboarding ? .completed : .todo
    case .activateAutofill:
      return isAutofillActivated ? .completed : .todo
    case .mobileToDesktop:
      return hasFinishedM2WAtLeastOnce ? .completed : .todo
    case .fixBreachedAccounts:
      return hasSeenDWMExperience ? .completed : .todo
    case .seeScanResult:
      return hasPassedPasswordOnboarding ? .completed : .todo
    }
  }
}
