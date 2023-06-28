import SwiftUI
import UIDelight
import UIComponents

struct PasswordLessCompletionView: View {
    enum Step {
        case animation
        case recoverySetup
    }

    @State
    var steps: [Step] = [.animation]

    @StateObject
    var model: PasswordLessCompletionViewModel

    init(model: @autoclosure @escaping () -> PasswordLessCompletionViewModel) {
        self._model = .init(wrappedValue: model())
    }

    var body: some View {
        StepBasedContentNavigationView(steps: $steps) { step in
            switch step {
            case .animation:
                animation
            case .recoverySetup:
                AccountRecoveryActivationEmbeddedFlow(model: model.makeAccountRecoveryActivationFlowModel())
                    .navigationBarHidden(false) 

            }
        }
    }

    var animation: some View {
        VStack(spacing: 45) {
            LottieView(.passwordChangerSuccess, loopMode: .playOnce)
                .frame(width: 77, height: 77)

            Text(L10n.Localizable.PasswordlessAccountCreation.Complete.title)
                .textStyle(.title.section.large)
                .foregroundColor(.ds.text.neutral.catchy)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .navigationBarHidden(true)
        .loginAppearance()
        .task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            steps.append(.recoverySetup)
        }
    }
}

 struct PasswordLessCompletionView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordLessCompletionView(model: .init(accountRecoveryActivationFlowFactory: .init { _, _ in .mock }, completion: {

        }))
    }
 }
