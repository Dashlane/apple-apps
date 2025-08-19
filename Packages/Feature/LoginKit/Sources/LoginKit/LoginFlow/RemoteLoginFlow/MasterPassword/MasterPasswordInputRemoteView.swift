import Combine
import CoreLocalization
import CoreSession
import CoreTypes
import DesignSystem
import SwiftTreats
import SwiftUI
import UIComponents
import UIDelight

struct MasterPasswordInputRemoteView: View {
  @StateObject
  var model: MasterPasswordInputRemoteViewModel

  public init(model: @escaping @autoclosure () -> MasterPasswordInputRemoteViewModel) {
    self._model = .init(wrappedValue: model())
  }

  @State
  var forgotButtonHelpDisplayed: Bool = false

  @FocusState
  var isTextFieldFocused: Bool

  public var body: some View {
    ZStack {
      switch model.viewState {
      case .masterPassword:
        mainView
          .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
              if !Device.is(.pad, .mac, .vision) {
                Button(CoreL10n.kwNext, action: validate)
                  .disabled(model.inProgress || model.password.isEmpty)
              }
            }
          }
      case .accountRecovery(let authTicket):
        AccountRecoveryKeyLoginFlow(
          model: model.makeAccountRecoveryFlowModel(authTicket: authTicket))
      }
    }
    .animation(.default, value: model.viewState)
    .onAppear(perform: model.onViewAppear)
    .loading(model.inProgress)
  }

  var mainView: some View {
    LoginContainerView(
      topView: LoginLogo(login: self.model.login),
      centerView: passwordField,
      bottomView: bottomView
    )
  }

  var bottomView: some View {
    VStack(spacing: 8) {
      if Device.is(.pad, .mac, .vision) {
        Button(CoreL10n.kwLoginNow, action: validate)
          .buttonStyle(.designSystem(.titleOnly))
          .disabled(self.model.inProgress || self.model.password.isEmpty)

        forgotPasswordButton
      } else {
        forgotPasswordButton
      }
    }
    .padding(.vertical, 12)
  }

  private var forgotPasswordButton: some View {
    Button(CoreL10n.forgotMpSheetTitle) {
      self.forgotButtonHelpDisplayed = true
    }
    .style(intensity: .supershy)
    .buttonStyle(.designSystem(.titleOnly))
    .modifier(
      ForgotMasterPasswordSheetModifier(
        model: model.makeForgotMasterPasswordSheetModel(),
        hasAccountRecoveryKey: $model.isAccountRecoveryEnabled,
        showForgotMasterPasswordSheet: $forgotButtonHelpDisplayed
      )
    )
  }

  private var passwordField: some View {
    DS.PasswordField(
      CoreL10n.masterPassword,
      placeholder: CoreL10n.kwEnterYourMasterPassword,
      text: $model.password,
      feedback: {
        if let errorMessage = model.errorMessage {
          FieldTextualFeedback(errorMessage)
            .style(.error)
        }
      }
    )
    .style(model.showWrongPasswordError ? .error : nil)
    .focused($isTextFieldFocused)
    .onSubmit {
      validate()
    }
    .disabled(model.inProgress)
    .submitLabel(.go)
    .shakeAnimation(forNumberOfAttempts: model.attempts)
    .copyErrorMessageAction(errorMessage: model.errorMessage)
    .onAppear {
      self.isTextFieldFocused = true
    }
    .onChange(of: model.showWrongPasswordError) { _, wrongPassword in
      guard wrongPassword == true else { return }
      DispatchQueue.main.async {
        self.isTextFieldFocused = true
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        UIAccessibility.post(
          notification: .announcement, argument: CoreL10n.kwWrongMasterPasswordTryAgain)
      }
    }
  }

  private func validate() {
    UIApplication.shared.endEditing()
    Task {
      await model.validate()
    }
  }
}

#Preview {
  MasterPasswordInputRemoteView(model: .mock)
}
