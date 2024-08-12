import SwiftUI
import UIDelight

struct DWMOnboardingFlow: View {

  @StateObject
  var viewModel: DWMOnboardingFlowViewModel

  init(viewModel: @autoclosure @escaping () -> DWMOnboardingFlowViewModel) {
    self._viewModel = .init(wrappedValue: viewModel())
  }

  var body: some View {
    StepBasedContentNavigationView(steps: $viewModel.steps) { step in
      switch step {
      case .dwmCheckSuggested:
        DWMRegistrationInGuidedOnboardingView(
          viewModel: viewModel.makeRegistrationViewForGuidedOnboardingViewModel()
        ) { viewModel.handleRegistrationInGuidedOnboardingViewAction($0) }
      case .emailConfirmation(let status):
        DWMEmailConfirmationView(
          viewModel: viewModel.makeEmailConfirmationViewModel(emailStatusCheck: status),
          transitionHandler: viewModel.transitionHandler
        ) { viewModel.handleEmailConfirmationViewAction($0) }
      }
    }
  }
}
