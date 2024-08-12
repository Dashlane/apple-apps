#if canImport(UIKit)
  import Foundation
  import SwiftUI
  import Combine
  import UIDelight
  import SwiftTreats
  import DashTypes
  import UIComponents
  import DesignSystem
  import CoreLocalization

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
        .navigationTitle(L10n.Core.kwLoginVcLoginButton)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
          Task { await model.onViewAppear() }
        }
        .loading(isLoading: model.inProgress, loadingIndicatorOffset: true)
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
          if !Device.isIpadOrMac {
            NavigationBarButton(
              action: self.validateToken,
              title: L10n.Core.kwNext
            )
            .disabled(!self.model.canLogin)
          }
        }
      }
    }

    private var calloutAndCodeField: some View {
      VStack {
        Text(L10n.Core.kwTokenMsg)
          .font(.callout)
          .fixedSize(horizontal: false, vertical: true)
          .multilineTextAlignment(.leading)
          .lineLimit(nil)
        DS.TextField(L10n.Core.kwTokenPlaceholderText, text: $model.token)
          .focused($isTextFieldFocused)
          .onSubmit {
            self.validateToken()
          }
          .style(intensity: .supershy)
          .keyboardType(.numberPad)
          .textInputAutocapitalization(.never)
          .submitLabel(.continue)
          .disabled(model.inProgress)
          .bubbleErrorMessage(text: $model.errorMessage)
          .copyErrorMessageAction(errorMessage: model.errorMessage)
          .onAppear {
            isTextFieldFocused = true
          }
      }
    }

    private var bottomView: some View {
      VStack(spacing: 8) {
        if Device.isIpadOrMac {
          Button(L10n.Core.kwNext) {
            validateToken()
          }
          .disabled(!self.model.canLogin)
        }
        resendTokenButton
      }
      .buttonStyle(.designSystem(.titleOnly))
      .padding(.vertical, 12)
    }

    private var resendTokenButton: some View {
      Button(L10n.Core.troubleWithToken) {
        displayResendAlert = true
      }
      .style(intensity: .supershy)
      .alert(
        L10n.Core.tokenNotWorkingTitle,
        isPresented: $displayResendAlert,
        actions: {
          Button(L10n.Core.actionResend) {
            Task {
              await self.model.requestToken()
            }
            self.model.logResendToken()
          }
          Button(L10n.Core.cancel, role: .cancel) {}
        },
        message: {
          Text(L10n.Core.tokenNotWorkingBody)
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

  struct TokenVerificationView_Previews: PreviewProvider {
    static var previews: some View {
      MultiDevicesPreview {
        TokenVerificationView(model: .mock)
      }
    }
  }
#endif
