import Combine
import CoreLocalization
import CoreTypes
import DesignSystem
import Foundation
import SwiftTreats
import SwiftUI
import UIComponents
import UIDelight

struct TokenVerificationView: View {

  @StateObject
  var model: TokenVerificationViewModel

  @Environment(\.dismiss)
  private var dismiss

  @State
  var displayResendAlert: Bool = false

  @FocusState
  var isTextFieldFocused: Bool

  init(model: @escaping @autoclosure () -> TokenVerificationViewModel) {
    self._model = .init(wrappedValue: model())
  }

  var body: some View {
    mainStack
      .navigationTitle(CoreL10n.kwLoginVcLoginButton)
      .navigationBarTitleDisplayMode(.inline)
      .onAppear {
        Task { await model.onViewAppear() }
      }
      .loading(Device.is(.pad, .mac, .vision) ? false : model.inProgress)
  }

  @ViewBuilder
  private var mainStack: some View {
    LoginContainerView(
      topView: LoginLogo(login: model.login),
      centerView: calloutAndCodeField,
      bottomView: bottomView
    )
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        if !Device.is(.pad, .mac, .vision) {
          Button(CoreL10n.kwNext, action: self.validateToken)
            .disabled(!self.model.canLogin)
        }
      }
    }
  }

  private var calloutAndCodeField: some View {
    VStack {
      Text(CoreL10n.kwTokenMsg)
        .font(.callout)
        .foregroundStyle(Color.ds.text.neutral.standard)
        .fixedSize(horizontal: false, vertical: true)
        .multilineTextAlignment(.leading)
        .lineLimit(nil)
      DS.TextField(
        CoreL10n.kwTokenPlaceholderText, text: $model.token,
        feedback: {
          if let errorMessage = model.errorMessage {
            FieldTextualFeedback(errorMessage)
              .style(.error)
          }
        }
      )
      .focused($isTextFieldFocused)
      .onSubmit {
        self.validateToken()
      }
      .style(intensity: .supershy)
      .keyboardType(.numberPad)
      .textInputAutocapitalization(.never)
      .submitLabel(.continue)
      .disabled(model.inProgress)
      .copyErrorMessageAction(errorMessage: model.errorMessage)
      .onAppear {
        isTextFieldFocused = true
      }
    }
  }

  private var bottomView: some View {
    VStack(spacing: 8) {
      if Device.is(.pad, .mac, .vision) {
        Button(CoreL10n.kwNext) {
          validateToken()
        }
        .disabled(!self.model.canLogin)
        .buttonDisplayProgressIndicator(model.inProgress)
      }
      resendTokenButton
    }
    .buttonStyle(.designSystem(.titleOnly))
    .padding(.vertical, 12)
  }

  private var resendTokenButton: some View {
    Button(CoreL10n.troubleWithToken) {
      displayResendAlert = true
    }
    .style(intensity: .supershy)
    .alert(
      CoreL10n.tokenNotWorkingTitle,
      isPresented: $displayResendAlert,
      actions: {
        Button(CoreL10n.actionResend) {
          Task {
            await self.model.requestToken()
          }
          self.model.logResendToken()
        }
        Button(CoreL10n.cancel, role: .cancel) {}
      },
      message: {
        Text(CoreL10n.tokenNotWorkingBody)
      }
    )
  }

  private func validateToken() {
    UIApplication.shared.endEditing()
    Task {
      await model.validateToken()
    }
  }
}

#Preview {
  TokenVerificationView(model: .mock)
}
