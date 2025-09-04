import Combine
import CoreLocalization
import CoreSession
import CoreTypes
import DesignSystem
import Lottie
import SwiftTreats
import SwiftUI
import UIComponents
import UIDelight
import UIKit
import UserTrackingFoundation

public struct LoginInputView: View {
  @StateObject
  private var model: LoginInputViewModel

  @State
  private var isSheetPresented: Bool = false

  @FocusState
  var isTextFieldFocused: Bool

  public init(
    model: @autoclosure @escaping () -> LoginInputViewModel, isTextFieldFocused: Bool = false
  ) {
    self._model = .init(wrappedValue: model())
    self.isTextFieldFocused = isTextFieldFocused
  }

  public var body: some View {
    mainStack
      .navigationBarBackButtonHidden(true)
      .navigationTitle(CoreL10n.kwLoginVcLoginButton)
      .navigationBarTitleDisplayMode(.inline)
      .loading(model.inProgress)
      .reportPageAppearance(.loginEmail)
      .sheet(isPresented: $isSheetPresented) {
        DebugAccountList(viewModel: self.model.makeDebugAccountViewModel()) { login in
          self.model.email = login.email
          self.isSheetPresented = false
          self.login()
        }
      }
      #if DEBUG
        .performOnShakeOrShortcut {
          isSheetPresented = true
        }
      #endif
  }

  @ViewBuilder
  private var mainStack: some View {
    LoginContainerView(
      topView: LoginLogo(),
      centerView: centerView,
      bottomView: bottomView
    )
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        Button(CoreL10n.cancel, role: .cancel, action: model.cancel)
      }
      ToolbarItem(placement: .navigationBarTrailing) {
        if !Device.is(.pad, .mac, .vision) {
          Button(CoreL10n.kwNext, action: login)
            .disabled(!model.canLogin)
        }
      }
    }
  }

  private var loginField: some View {
    DS.TextField(
      CoreL10n.kwEmailIOS,
      placeholder: CoreL10n.kwEmailTitle,
      text: $model.email,
      actions: {
        if !model.email.isEmpty {
          DS.FieldAction.ClearContent(text: $model.email)
        }
      },
      feedback: {
        if let errorMessage = model.bubbleErrorMessage {
          FieldTextualFeedback(errorMessage)
            .style(.error)
        }
      }
    )
    .focused($isTextFieldFocused)
    .onSubmit(login)
    .keyboardType(.emailAddress)
    .submitLabel(.continue)
    .textInputAutocapitalization(.never)
    .textContentType(.emailAddress)
    .autocorrectionDisabled(true)
    .disabled(model.inProgress)
    .copyErrorMessageAction(errorMessage: model.bubbleErrorMessage)
    .alert(item: $model.currentAlert) { item in
      switch item {
      case .ssoBlockedAlert:
        Alert(
          title: Text(CoreL10n.ssoBlockedError), dismissButton: .default(Text(CoreL10n.kwButtonOk)))
      case .userDeactivatedAlert:
        Alert(
          title: Text(CoreL10n.Login.deactivatedUserErrorTitle),
          dismissButton: .default(Text(CoreL10n.kwButtonOk)))
      case .versionValidityAlert:
        Alert(
          title: Text(CoreL10n.validityStatusExpiredVersionNoUpdateTitle),
          message: Text(CoreL10n.validityStatusExpiredVersionNoUpdateDesc),
          dismissButton: .cancel(Text(CoreL10n.validityStatusExpiredVersionNoUpdateClose)))
      }
    }
    .onAppear {
      isTextFieldFocused = true
    }
  }

  private var centerView: some View {
    VStack(alignment: .leading, spacing: 8) {
      loginField
      VStack(alignment: .leading, spacing: 8) {
        Text(CoreL10n.deviceToDeviceLoginCaption)
          .foregroundStyle(Color.ds.text.neutral.quiet)
        Button(
          action: {
            model.deviceToDeviceLogin()
          },
          label: {
            Text(CoreL10n.deviceToDeviceLoginCta)
              .foregroundStyle(Color.ds.text.brand.standard)
          })
      }
    }
  }

  @ViewBuilder
  private var bottomView: some View {
    if Device.is(.pad, .mac, .vision) {
      Button(CoreL10n.kwNext, action: login)
        .buttonStyle(.designSystem(.titleOnly))
        .disabled(!model.canLogin || model.inProgress)
    }
  }

  private func login() {
    UIApplication.shared.endEditing()
    Task {
      await model.login()
    }
  }
}

struct LoginView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      LoginInputView(model: .mock)
    }
  }
}
