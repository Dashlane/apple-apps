#if canImport(UIKit)
import SwiftUI
import UIDelight
import UIComponents
import CoreLocalization

struct LocalLoginUnlockView: View {
    @StateObject
    var viewModel: LocalLoginUnlockViewModel

    @Environment(\.dismiss)
    private var dismiss

    public init(viewModel: @autoclosure @escaping () -> LocalLoginUnlockViewModel) {
        self._viewModel = .init(wrappedValue: viewModel())
    }

    var body: some View {
        ZStack {
            unlockView
                .navigation(isActive: $viewModel.showRememberPassword) {
                    LockLoadingView(login: viewModel.localLoginHandler.login) {
                        Task {
                            await self.viewModel.rememberPassword()
                        }
                    }
                }
                .transition(.opacity)
                .onAppear {
                    self.viewModel.logOnAppear()
                }
        }
        .animation(.default, value: viewModel.unlockMode)
    }

    @ViewBuilder
    private var unlockView: some View {
        switch viewModel.unlockMode {
        case .masterPassword:
            MasterPasswordView(model: viewModel.masterPasswordLocalViewModel)
                .toolbar { ToolbarItem(placement: .navigationBarLeading) { cancelButton } }
                .navigationBarBackButtonHidden(viewModel.context.isExtension)
        case let .biometry(model):
            BiometryView(model: model)
        case let .pincode(model):
            LockPinCodeAndBiometryView(model: model)
        }
    }

    @ViewBuilder
    private var cancelButton: some View {
        if case let .autofillExtension(cancelAction) = viewModel.context {
            NavigationBarButton(action: {
                cancelAction()
            },
                                title: L10n.Core.cancel)
        }
    }
}
#endif
