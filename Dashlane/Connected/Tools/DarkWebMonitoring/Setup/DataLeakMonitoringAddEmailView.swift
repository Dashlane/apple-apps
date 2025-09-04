import CoreLocalization
import DesignSystem
import LoginKit
import SwiftUI
import UIComponents
import UIDelight

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
    StepBasedNavigationView(
      steps: $viewModel.steps,
      content: { step in
        switch step {
        case .enterEmail:
          GravityAreaVStack(
            top: title,
            center: emailField,
            bottom: validationButton,
            alignment: .leading, spacing: 20
          )
          .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
          .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
              Button(
                action: {
                  dismiss()
                },
                label: {
                  Text(CoreL10n.cancel)
                    .foregroundStyle(Color.ds.text.brand.standard)
                })
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
      .foregroundStyle(Color.ds.text.neutral.standard)
      .bold()
      .padding()
  }

  var emailField: some View {
    LoginFieldBox {
      DS.TextField(
        CoreL10n.kwEmailTitle,
        text: $viewModel.emailToMonitor,
        feedback: {
          if let errorMessage = viewModel.errorMessage {
            FieldTextualFeedback(errorMessage)
              .style(.error)
          }
        }
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
  }

  var validationButton: some View {
    Button(L10n.Localizable.dataleakmonitoringNoEmailStartCta, action: startMonitoring)
      .buttonDisplayProgressIndicator(viewModel.isRegisteringEmail)
      .buttonStyle(.designSystem(.titleOnly))
      .padding()
  }

  func startMonitoring() {
    Task {
      await viewModel.monitorEmail()
    }
  }

  var successView: some View {
    DataLeakMonitoringAddEmailSuccessView(
      dismiss: dismiss, monitoredEmail: viewModel.emailToMonitor)
  }
}

struct DataLeakMonitoringAddEmailView_Previews: PreviewProvider {
  static var previews: some View {
    DataLeakMonitoringAddEmailView(viewModel: DataLeakMonitoringAddEmailViewModel.mock)
  }
}
