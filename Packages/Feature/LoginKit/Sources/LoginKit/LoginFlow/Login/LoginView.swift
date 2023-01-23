#if canImport(UIKit)
import UIKit
import SwiftUI
import Combine
import CoreSession
import Lottie
import UIDelight
import SwiftTreats
import UIComponents
import CoreLocalization
import CoreUserTracking
import DesignSystem
import DashTypes

public struct LoginView<Model: LoginViewModelProtocol>: View {
    @ObservedObject
    private var model: Model

    @Environment(\.dismiss)
    private var dismiss

    @State
    private var isSheetPresented: Bool = false

    @FocusState
    var isTextFieldFocused: Bool

    public init(model: Model, isTextFieldFocused: Bool = false) {
        self.model = model
        self.isTextFieldFocused = isTextFieldFocused
    }

    public var body: some View {
        mainStack
            .loginAppearance()
            .navigationBarBackButtonHidden(true)
            .navigationTitle(L10n.Core.kwLoginVcLoginButton)
            .navigationBarTitleDisplayMode(.inline)
            .loading(isLoading: model.inProgress, loadingIndicatorOffset: true)
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
        if Device.isIpadOrMac {
            vStackIpadMac
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        NavigationBarButton(action: {
                            self.model.cancel()
                        },
                                            title: L10n.Core.cancel)
                    }
                }
        } else {
            vStackIphone
        }
    }

    private var vStackIphone: some View {
        GravityAreaVStack(top: LoginLogo(),
                          center: loginField,
                          bottom: KeyboardSpacer(),
                          spacing: 0)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationBarButton(action: {
                    self.model.cancel()
                },
                                    title: L10n.Core.cancel)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationBarButton(action: login,
                                    title: L10n.Core.kwNext)
                    .disabled(!model.canLogin)
            }
        }
    }

    private var vStackIpadMac: some View {
        VStack(alignment: .center, spacing: 0) {
            LoginLogo()

            loginField

            HStack {
                Spacer()

                Button(action: login, title: L10n.Core.kwNext)
                    .buttonStyle(.login)
                    .frame(alignment: .center)
                    .disabled(!model.canLogin || model.inProgress)

                Spacer()
            }
            .padding(.top, 40)

            KeyboardSpacer()

            Spacer()
                .frame(maxHeight: .infinity)
        }
    }

    private var loginField: some View {
        LoginFieldBox {
            TextInput(L10n.Core.kwEmailTitle, text: $model.email)
                .focused($isTextFieldFocused)
                .onSubmit(login)
                .style(intensity: .supershy)
                .keyboardType(.emailAddress)
                .submitLabel(.continue)
                .textInputAutocapitalization(.never)
                .textContentType(.emailAddress)
                .autocorrectionDisabled(true)
                .disabled(model.inProgress)
        }
        .bubbleErrorMessage(text: $model.bubbleErrorMessage)
        .alert(presenting: $model.currentAlert)
        .didAppear { 
            isTextFieldFocused = true
            model.resetLoginUsageLogs()
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
    class FakeModel: LoginViewModelProtocol {

        @Published
        var currentAlert: AlertContent?

        @Published
        var bubbleErrorMessage: String?

        @Published
        var email: String

        @Published
        var inProgress: Bool

        init(email: String,
             inProgress: Bool = false,
             currentAlert: AlertContent? = nil,
             bubbleErrorMessage: String? = nil) {
            self.email = email
            self.inProgress = inProgress
            self.currentAlert = currentAlert
            self.bubbleErrorMessage = bubbleErrorMessage
        }

        func login() {}
        func cancel() {}
        func resetLoginUsageLogs() {}
        func updateApp() {}
        func makeDebugAccountViewModel() -> DebugAccountListViewModel { .mock }
    }

    static var previews: some View {
        MultiContextPreview {
            NavigationView {
                LoginView(model: FakeModel(email: "_"))
            }

            NavigationView {
                LoginView(model: FakeModel(email: "_", bubbleErrorMessage: "This is a bubble error!"))
            }

            NavigationView {
                LoginView(model: FakeModel(email: "_", inProgress: true))
            }

            NavigationView {
                LoginView(model: FakeModel(email: "_", currentAlert: .init(title: "Test alert")))
            }
        }.accentColor(.ds.text.brand.standard)
    }
}
#endif
