import Combine
import CoreLocalization
import CoreSession
import CoreTypes
import DesignSystem
import SwiftTreats
import SwiftUI
import UIComponents
import UIDelight

public struct MasterPasswordLocalView: View {
  public init(model: @escaping @autoclosure () -> MasterPasswordLocalViewModel) {
    self._model = .init(wrappedValue: model())
  }

  @StateObject
  private var model: MasterPasswordLocalViewModel

  @State
  var forgotButtonHelpDisplayed: Bool = false

  @FocusState
  var isTextFieldFocused: Bool

  @State
  private var logoutConfirmationDisplayed = false

  public var body: some View {
    ZStack {
      switch model.viewState {
      case .masterPassword:
        passwordView
          .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
              if !Device.is(.pad, .mac, .vision) {
                Button(CoreL10n.kwNext, action: { Task { await self.validate() } })
                  .disabled(self.model.isValidationInProgress || self.model.password.isEmpty)
              }
            }
          }
          .reportPageAppearance(.unlockMp)
      case .accountRecovery(let state, let loginType):
        AccountRecoveryKeyLoginFlow(
          model: model.makeAccountRecoveryFlowModel(state: state, loginType: loginType)
        )
        .navigationTitle(CoreL10n.accountRecoveryNavigationTitle)
      }
    }
    .animation(.default, value: model.viewState)
    .onAppear(perform: model.onViewAppear)
  }

  @ViewBuilder
  var passwordView: some View {
    switch model.context.origin {
    case .lock:
      mainView
        .navigationBarBackButtonHidden(true)
        .toolbar {
          ToolbarItem(placement: .navigationBarLeading) {
            Button(CoreL10n.kwLogOut) {
              logoutConfirmationDisplayed = true
            }
          }
        }
        .alert(
          CoreL10n.askLogout,
          isPresented: $logoutConfirmationDisplayed,
          actions: {
            Button(CoreL10n.cancel, role: .cancel) {}

            Button(CoreL10n.kwSignOut, role: .destructive) {
              Task {
                await self.model.perform(.logout)
              }
            }
          },
          message: {
            Text(CoreL10n.signoutAskMasterPassword)
          }
        )
    case .login:
      mainView
    }
  }

  @ViewBuilder
  var mainView: some View {
    LoginContainerView(
      topView: topView,
      centerView: passwordField,
      bottomView: bottomView
    )
  }

  private var topView: some View {
    VStack(spacing: 38) {
      LoginLogo(login: model.login)
        .fixedSize(horizontal: false, vertical: true)
      if let biometry = model.biometry {
        Button(
          action: { model.showBiometryView() },
          label: {
            Image(biometry: biometry)
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(width: 40, height: 40)
              .foregroundStyle(Color.ds.text.neutral.catchy)
          }
        )
      }
    }
  }

  private var passwordField: some View {
    VStack {
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
      .fieldEditionDisabled(model.isValidationInProgress)
      .onSubmit {
        Task { await validate() }
      }
      .submitLabel(.go)
      .shakeAnimation(forNumberOfAttempts: model.attempts)
    }
    .copyErrorMessageAction(errorMessage: model.errorMessage)
    .onAppear {
      self.isTextFieldFocused = true
    }
    .onChange(of: model.showWrongPasswordError) { _, show in
      guard show else { return }
      DispatchQueue.main.async {
        isTextFieldFocused = true
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        UIAccessibility.post(
          notification: .announcement, argument: CoreL10n.kwWrongMasterPasswordTryAgain)
      }
    }
  }

  var bottomView: some View {
    VStack(spacing: 8) {
      if Device.is(.pad, .mac, .vision) {
        Button(CoreL10n.kwLoginNow) {
          Task { await self.validate() }
        }
        .buttonStyle(.designSystem(.titleOnly))
        .disabled(self.model.isValidationInProgress || self.model.password.isEmpty)

        forgotPasswordButton
      } else {
        forgotPasswordButton
      }
    }
    .padding(.vertical, 12)
  }

  private var forgotPasswordButton: some View {
    Button(CoreL10n.forgotMpSheetTitle) {
      forgotButtonHelpDisplayed = true
    }
    .buttonStyle(.designSystem(.titleOnly))
    .style(intensity: .supershy)
    .modifier(
      ForgotMasterPasswordSheetModifier(
        model: model.makeForgotMasterPasswordSheetModel(),
        hasAccountRecoveryKey: $model.hasAccountRecoveryKey,
        showForgotMasterPasswordSheet: $forgotButtonHelpDisplayed
      )
    )
  }

  private func validate() async {
    UIApplication.shared.endEditing()
    Task {
      try await model.validate()
    }
  }
}

#Preview {
  NavigationStack {
    MasterPasswordLocalView(model: .mock)
  }
}
