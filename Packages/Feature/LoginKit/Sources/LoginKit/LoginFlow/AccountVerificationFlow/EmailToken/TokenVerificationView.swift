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

    @ObservedObject
    var model: TokenVerificationViewModel

    @Environment(\.dismiss)
    private var dismiss

    @State
    var displayResendAlert: Bool = false

    @FocusState
    var isTextFieldFocused: Bool

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
            ToolbarItem(placement: .navigationBarLeading) {
                if Device.isIpadOrMac {
                    NavigationBarButton(
                        action: dismiss.callAsFunction,
                        title: L10n.Core.kwBack
                    )
                }
            }
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
                DS.Button(L10n.Core.kwNext) {
                    validateToken()
                }
                .disabled(!self.model.canLogin)
            }
            resendTokenButton
        }
        .roundedButtonLayout(.fill)
        .padding(.vertical, 12)
    }

    private var resendTokenButton: some View {
        DS.Button(L10n.Core.troubleWithToken) {
            displayResendAlert = true
        }
        .style(intensity: .supershy)
        .alert(isPresented: $displayResendAlert, content: resendTokenAlert)
    }

    private func resendTokenAlert() -> Alert {
        Alert(title: Text(L10n.Core.tokenNotWorkingTitle),
              message: Text(L10n.Core.tokenNotWorkingBody),
              primaryButton:
                .default(Text(L10n.Core.actionResend)) {
                    Task {
                        await self.model.requestToken()
                    }
                    self.model.logResendToken()
                },
              secondaryButton: .cancel {})
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
        MultiDevicesPreview() {
            TokenVerificationView(model: .mock)
        }
    }
}
#endif
