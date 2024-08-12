import LoginKit
import SwiftUI
import UIDelight

@MainActor
public struct GuidedOnboardingFlow: View {
  @StateObject
  var model: GuidedOnboardingFlowViewModel

  init(model: @escaping @autoclosure () -> GuidedOnboardingFlowViewModel) {
    self._model = .init(wrappedValue: model())
  }

  public var body: some View {
    StepBasedContentNavigationView(steps: $model.steps) { step in
      switch step {
      case .introQuestion:
        AccountCreationSurveyView { choice in model.introQuestionAnswered(choice) }
      case let .survey(surveyStep):
        model.makeGuidedOnboardingView(step: surveyStep)
      case .darkWebMonitoringOnboarding:
        model.makeDarkWebMonitoringOnboardingFlow()
      case .creatingPlan:
        model.makeCreatingPlanView()
      }
    }
  }
}
