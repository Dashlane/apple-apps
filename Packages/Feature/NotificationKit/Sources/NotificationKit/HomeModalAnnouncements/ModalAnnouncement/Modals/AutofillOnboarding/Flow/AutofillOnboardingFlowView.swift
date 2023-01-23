import SwiftUI
import UIDelight
import DesignSystem

public struct AutofillOnboardingFlowView: View {
    @StateObject
    var model: AutofillOnboardingFlowViewModel

    public init(model: @autoclosure @escaping () -> AutofillOnboardingFlowViewModel) {
        self._model = .init(wrappedValue: model())
    }

    public var body: some View {
        StepBasedNavigationView(steps: $model.steps) { step in
            switch step {
            case .intro(let model):
                AutofillOnboardingIntroView(model: model)
            case .instructions(let model):
                AutofillOnboardingInstructionsView(model: model)
            case .success:
                AutofillOnboardingSuccessView(action: { model.finish() })
            }
        }
        .backgroundColorIgnoringSafeArea(.ds.background.default)
        .padding(.bottom, 20)
        .onAppear(perform: model.onAppear)
    }
}
