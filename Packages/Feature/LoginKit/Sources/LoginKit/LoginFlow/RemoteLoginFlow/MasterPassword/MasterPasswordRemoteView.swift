#if canImport(UIKit)
  import SwiftUI
  import Combine
  import CoreSession
  import DashTypes
  import UIDelight
  import SwiftTreats
  import UIComponents
  import CoreLocalization
  import DesignSystem

  struct MasterPasswordRemoteView: View {
    @StateObject
    var model: MasterPasswordRemoteViewModel

    let showProgressIndicator: Bool

    public init(
      model: @escaping @autoclosure () -> MasterPasswordRemoteViewModel,
      showProgressIndicator: Bool = true
    ) {
      self._model = .init(wrappedValue: model())
      self.showProgressIndicator = showProgressIndicator
    }

    @State
    var forgotButtonHelpDisplayed: Bool = false

    @FocusState
    var isTextFieldFocused: Bool

    public var body: some View {
      ZStack {
        if model.showAccountRecoveryFlow {
          AccountRecoveryKeyLoginFlow(model: model.makeAccountRecoveryFlowModel())
        } else {
          mainView
            .toolbar {
              ToolbarItem(placement: .navigationBarTrailing) {
                if !Device.isIpadOrMac {
                  NavigationBarButton(action: validate, title: L10n.Core.kwNext)
                    .disabled(model.inProgress || model.password.isEmpty)
                }
              }
            }
        }
      }
      .animation(.default, value: model.showAccountRecoveryFlow)
      .onAppear(perform: model.onViewAppear)
      .loading(
        isLoading: model.inProgress && showProgressIndicator,
        loadingIndicatorOffset: true
      )
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
        if Device.isIpadOrMac {
          Button(L10n.Core.kwLoginNow, action: validate)
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
      Button(L10n.Core.forgotMpSheetTitle) {
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
        L10n.Core.masterPassword,
        placeholder: L10n.Core.kwEnterYourMasterPassword,
        text: $model.password
      )
      .style(model.showWrongPasswordError ? .error : nil)
      .focused($isTextFieldFocused)
      .onSubmit {
        validate()
      }
      .disabled(model.inProgress)
      .submitLabel(.go)
      .shakeAnimation(forNumberOfAttempts: model.attempts)
      .bubbleErrorMessage(text: $model.errorMessage)
      .copyErrorMessageAction(errorMessage: model.errorMessage)
      .onAppear {
        self.isTextFieldFocused = true
      }
      .onChange(of: model.showWrongPasswordError) {
        guard $0 == true else { return }
        DispatchQueue.main.async {
          self.isTextFieldFocused = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          UIAccessibility.post(
            notification: .announcement, argument: L10n.Core.kwWrongMasterPasswordTryAgain)
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

  struct MasterPasswordRemoteView_Previews: PreviewProvider {
    static var previews: some View {
      MultiDevicesPreview {
        MasterPasswordRemoteView(model: .mock)
      }
    }
  }
#endif
