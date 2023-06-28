import SwiftUI
import UIComponents
import DesignSystem
import UIDelight
import LoginKit
import CoreLocalization

struct DataLeakMonitoringAddEmailView: View {

    @Environment(\.dismiss)
    var dismiss

    @StateObject
    var viewModel: DataLeakMonitoringAddEmailViewModel

    @FocusState var isTextFieldFocused

    init(viewModel: @escaping @autoclosure () -> DataLeakMonitoringAddEmailViewModel) {
        self._viewModel = .init(wrappedValue: viewModel())
    }

    var body: some View {
        StepBasedNavigationView(steps: $viewModel.steps, content: { step in
            switch step {
            case .enterEmail:
                GravityAreaVStack(top: title,
                                  center: emailField,
                                  bottom: validationButton,
                                  alignment: .leading, spacing: 20)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(CoreLocalization.L10n.Core.cancel) {
                            dismiss()
                        }
                    }
                }
                .onAppear {
                    isTextFieldFocused = true
                }
            case .success:
                successView
            }
        })
    }

    var title: some View {
        Text(L10n.Localizable.dataleakmonitoringEnterEmailTitle)
            .font(.title2)
            .bold()
            .padding()
    }

    var emailField: some View {
        LoginFieldBox {
            DS.TextField(
                CoreLocalization.L10n.Core.kwEmailTitle,
                text: $viewModel.emailToMonitor
            )
            .focused($isTextFieldFocused)
            .onSubmit {
                startMonitoring()
            }
            .style(intensity: .supershy)
            .keyboardType(.emailAddress)
            .submitLabel(.next)
            .textInputAutocapitalization(.never)
            .textContentType(.emailAddress)
            .padding(.horizontal)
            .autocorrectionDisabled()
        }
        .bubbleErrorMessage(text: $viewModel.errorMessage)
    }

    var validationButton: some View {
        RoundedButton(L10n.Localizable.dataleakmonitoringNoEmailStartCta, action: startMonitoring)
            .roundedButtonDisplayProgressIndicator(viewModel.isRegisteringEmail)
            .roundedButtonLayout(.fill)
            .padding()
    }

    func startMonitoring() {
        Task {
            await viewModel.monitorEmail()
        }
    }

    var successView: some View {
        DataLeakMonitoringAddEmailSuccessView(dismiss: dismiss, monitoredEmail: viewModel.emailToMonitor)
    }
}

 struct DataLeakMonitoringAddEmailView_Previews: PreviewProvider {
    static var previews: some View {
        DataLeakMonitoringAddEmailView(viewModel: DataLeakMonitoringAddEmailViewModel.mock)
    }
 }
