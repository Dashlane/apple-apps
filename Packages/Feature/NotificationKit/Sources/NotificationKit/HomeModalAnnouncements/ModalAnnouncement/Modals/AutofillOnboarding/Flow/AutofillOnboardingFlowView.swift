import DesignSystem
import SwiftUI
import UIDelight

public struct AutofillOnboardingFlowView: View {
  @StateObject
  var model: AutofillOnboardingFlowViewModel

  public init(model: @autoclosure @escaping () -> AutofillOnboardingFlowViewModel) {
    self._model = .init(wrappedValue: model())
  }

  public var body: some View {
    StepBasedNavigationView(steps: $model.steps) { step in
      switch step {
      case .intro:
        AutofillOnboardingIntroView(model: model.makeAutofillOnboardingIntroViewModel())
      case .instructions:
        AutofillOnboardingInstructionsView(
          model: model.makeAutofillOnboardingInstructionsViewModel())
      case .success:
        AutofillOnboardingSuccessView(action: { model.finish() })
      }
    }
    .onAppear(perform: model.onAppear)
  }
}
