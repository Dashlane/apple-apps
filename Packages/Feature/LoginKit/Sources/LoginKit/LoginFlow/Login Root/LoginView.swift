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

public struct LoginView: View {
    @StateObject
    private var model: LoginViewModel

    @State
    private var isSheetPresented: Bool = false

    @FocusState
    var isTextFieldFocused: Bool

    public init(model: @autoclosure @escaping () -> LoginViewModel, isTextFieldFocused: Bool = false) {
        self._model = .init(wrappedValue: model())
        self.isTextFieldFocused = isTextFieldFocused
    }

    public var body: some View {
        mainStack
            .navigationBarBackButtonHidden(true)
            .navigationTitle(L10n.Core.kwLoginVcLoginButton)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarStyle(.transparent)
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
        LoginContainerView(
            topView: LoginLogo(),
            centerView: centerView,
            bottomView: bottomView
        )
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if Device.isIpadOrMac {
                    NavigationBarButton(
                        action: { self.model.cancel() },
                        title: L10n.Core.cancel
                    )
                } else {
                    NavigationBarButton(
                        action: { self.model.cancel() },
                        title: L10n.Core.cancel
                    )
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if !Device.isIpadOrMac {
                    NavigationBarButton(
                        action: login,
                        title: L10n.Core.kwNext
                    )
                    .disabled(!model.canLogin)
                }
            }
        }
    }

    private var loginField: some View {
        DS.TextField(
            L10n.Core.kwEmailIOS,
            placeholder: L10n.Core.kwEmailTitle,
            text: $model.email,
            actions: {
                if !model.email.isEmpty {
                    TextFieldAction.ClearContent(text: $model.email)
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
        .bubbleErrorMessage(text: $model.bubbleErrorMessage)
        .copyErrorMessageAction(errorMessage: model.bubbleErrorMessage)
        .alert(presenting: $model.currentAlert)
        .onAppear {
            isTextFieldFocused = true
            model.resetLoginUsageLogs()
        }
    }

    private var centerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            loginField
            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.Core.deviceToDeviceLoginCaption)
                    .foregroundColor(.ds.text.neutral.quiet)
                Button(action: {
                    model.deviceToDeviceLogin()
                }, label: {
                    Text(L10n.Core.deviceToDeviceLoginCta)
                        .foregroundColor(.ds.text.brand.standard)
                })
            }
        }
    }
    
    @ViewBuilder
    private var bottomView: some View {
        if Device.isIpadOrMac {
            DS.Button(L10n.Core.kwNext, action: login)
                .roundedButtonLayout(.fill)
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
            LoginView(model: .mock)
        }
    }
}
#endif
