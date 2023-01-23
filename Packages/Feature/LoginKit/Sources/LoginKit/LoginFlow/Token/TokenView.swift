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

public struct TokenView<Model: TokenViewModelProtocol>: View {
    @ObservedObject
    var model: Model

    @Environment(\.dismiss)
    private var dismiss

    @State
    var displayResendAlert: Bool = false

    @FocusState
    var isTextFieldFocused: Bool

    public init(model: Model) {
        self.model = model
    }

    public var body: some View {
        mainStack
            .loginAppearance()
            .navigationTitle(L10n.Core.kwLoginVcLoginButton)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                self.model.logShowToken()
                Task {
                    await model.requestToken()
                }
                #if DEBUG
                if self.model.login.isTest, !ProcessInfo.isTesting {
                    self.model.autofillToken()
                }
                #endif
            }
            .loading(isLoading: model.inProgress, loadingIndicatorOffset: true)
    }

    @ViewBuilder
    private var mainStack: some View {
        if Device.isIpadOrMac {
            vStackIpadMac
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        NavigationBarButton(action: dismiss.callAsFunction,
                                            title: L10n.Core.kwBack)
                    }
                }
        } else {
            vStackIphone
        }
    }

    private var vStackIphone: some View {
        GravityAreaVStack(top: LoginLogo(login: self.model.login),
                          center: self.calloutAndCodeField,
                          bottom: VStack {
                            self.resendTokenButton
                            KeyboardSpacer()
                          }, spacing: 0)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationBarButton(action: self.validateToken,
                                    title: L10n.Core.kwNext)
                .disabled(!self.model.canLogin)
            }
        }
    }

    private var vStackIpadMac: some View {
        VStack(alignment: .center, spacing: 0) {
            LoginLogo(login: self.model.login)

            calloutAndCodeField

            HStack {
                Spacer()

                Button(action: validateToken, title: L10n.Core.kwNext)
                    .buttonStyle(.login)
                    .frame(alignment: .center)
                    .disabled(!self.model.canLogin)

                Spacer()
            }
            .padding(.top, 40)

            self.resendTokenButton
                .padding(15)

            KeyboardSpacer()

            Spacer()
                .frame(maxHeight: .infinity)
        }
    }

    private var calloutAndCodeField: some View {
        VStack {
            Text(L10n.Core.kwTokenMsg)
                .font(.callout)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
            LoginFieldBox {
                TextInput(L10n.Core.kwTokenPlaceholderText,
                          text: $model.token)
                .focused($isTextFieldFocused)
                .onSubmit {
                    self.validateToken()
                }
                .style(intensity: .supershy)
                .keyboardType(.numberPad)
                .textInputAutocapitalization(.never)
                .submitLabel(.continue)
                .disabled(model.inProgress)
            }
            .bubbleErrorMessage(text: $model.errorMessage)
            .onAppear {
                self.isTextFieldFocused = true
            }
        }
    }

    private var resendTokenButton: some View {
        Button(action: {
            self.displayResendAlert = true
            self.model.logger.logShowResentAlert()
        }, title: L10n.Core.troubleWithToken)
        .foregroundColor(.ds.text.brand.standard)
        .padding(5)
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
                    self.model.logger.logResentAlert()
                    self.model.logResendToken()
                },
              secondaryButton: .cancel {
                self.model.logger.logCancelResendAlert()
              })
    }

    private func validateToken() {
        UIApplication.shared.endEditing()
        model.validateToken()
    }

}

struct TokenView_Previews: PreviewProvider {
    class FakeModel: TokenViewModelProtocol {
        let logger = LoginInstallerLogger(installerLogService: FakeInstallerLogService())
        let login: Login = Login("_")

        @Published
        @MainActor
        var token: String

        @Published
        var errorMessage: String?

        @Published
        var inProgress: Bool

        @MainActor
        init(token: String = "", errorMessage: String? = nil, shouldDisplayError: Bool = false, inProgress: Bool = false) {
            self.token = token
            self.errorMessage = errorMessage
            self.inProgress = inProgress
        }

        @MainActor
        func requestToken() {}
        @MainActor
        func validateToken() {}
        @MainActor
        func autofillToken() {}
        func cancel() {}
        func logResendToken() {}
        func logShowToken() {}
    }

    static var previews: some View {
        MultiContextPreview {
            NavigationView {
                TokenView(model: FakeModel(token: ""))
            }

            NavigationView {
                TokenView(model: FakeModel(token: "123456", errorMessage: "Hey Error!"))
            }
            NavigationView {

                VStack {
                    TokenView(model: FakeModel(token: "123456", inProgress: true))

                }

            }

        }
    }
}
#endif
