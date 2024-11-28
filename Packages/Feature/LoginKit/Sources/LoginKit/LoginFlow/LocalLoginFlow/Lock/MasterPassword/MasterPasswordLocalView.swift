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

  public struct MasterPasswordLocalView: View {
    let showProgressIndicator: Bool

    public init(
      model: @escaping @autoclosure () -> MasterPasswordLocalViewModel,
      showProgressIndicator: Bool = true
    ) {
      self._model = .init(wrappedValue: model())
      self.showProgressIndicator = showProgressIndicator
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
                if !Device.isIpadOrMac {
                  NavigationBarButton(
                    action: { Task { await self.validate() } },
                    title: L10n.Core.kwNext
                  )
                  .disabled(self.model.inProgress || self.model.password.isEmpty)
                }
              }
            }
        case .accountRecovery(let state, let loginType):
          AccountRecoveryKeyLoginFlow(
            model: model.makeAccountRecoveryFlowModel(state: state, loginType: loginType)
          )
          .navigationTitle(L10n.Core.accountRecoveryNavigationTitle)
        }
      }
      .animation(.default, value: model.viewState)
      .onAppear(perform: model.onViewAppear)
      .loading(
        isLoading: model.inProgress && showProgressIndicator,
        loadingIndicatorOffset: true
      )
    }

    @ViewBuilder
    var passwordView: some View {
      switch model.context.origin {
      case .lock:
        mainView
          .navigationBarBackButtonHidden(true)
          .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
              NavigationBarButton(
                action: {
                  logoutConfirmationDisplayed = true
                },
                title: L10n.Core.kwLogOut
              )
            }
          }
          .alert(
            L10n.Core.askLogout,
            isPresented: $logoutConfirmationDisplayed,
            actions: {
              Button(L10n.Core.cancel, role: .cancel) {}

              Button(L10n.Core.kwSignOut, role: .destructive) {
                Task {
                  await self.model.perform(.logout)
                }
              }
            },
            message: {
              Text(L10n.Core.signoutAskMasterPassword)
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
        if model.biometry != nil {
          Button(
            action: { model.showBiometryView() },
            label: {
              Image(asset: model.biometry == .touchId ? Asset.fingerprint : Asset.faceId)
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(.ds.text.neutral.catchy)
            }
          )
        }
      }
    }

    private var biometryImage: Image {
      let imageAsset = model.biometry == .touchId ? Asset.fingerprint : Asset.faceId
      return imageAsset.swiftUIImage
    }

    private var passwordField: some View {
      VStack {
        DS.PasswordField(
          L10n.Core.masterPassword,
          placeholder: L10n.Core.kwEnterYourMasterPassword,
          text: $model.password
        )
        .style(model.showWrongPasswordError ? .error : nil)
        .focused($isTextFieldFocused)
        .onSubmit {
          Task { await validate() }
        }
        .disabled(model.inProgress)
        .submitLabel(.go)
        .shakeAnimation(forNumberOfAttempts: model.attempts)
      }
      .bubbleErrorMessage(text: $model.errorMessage)
      .copyErrorMessageAction(errorMessage: model.errorMessage)
      .onAppear {
        self.isTextFieldFocused = true
      }
      .onChange(of: model.showWrongPasswordError) { show in
        guard show else { return }
        DispatchQueue.main.async {
          isTextFieldFocused = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          UIAccessibility.post(
            notification: .announcement, argument: L10n.Core.kwWrongMasterPasswordTryAgain)
        }
      }
    }

    var bottomView: some View {
      VStack(spacing: 8) {
        if Device.isIpadOrMac {
          Button(L10n.Core.kwLoginNow) {
            Task { await self.validate() }
          }
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

  struct MasterPasswordLocalView_Previews: PreviewProvider {

    static var previews: some View {
      MultiDevicesPreview {
        NavigationView {
          MasterPasswordLocalView(
            model: .mock,
            showProgressIndicator: false
          )
        }
      }
    }
  }

#endif
