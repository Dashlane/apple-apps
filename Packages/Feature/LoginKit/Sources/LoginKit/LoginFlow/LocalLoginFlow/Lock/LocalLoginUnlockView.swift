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
            LockLoadingView(login: viewModel.login) {
              Task {
                await self.viewModel.authenticateUsingRememberPassword()
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
        MasterPasswordLocalView(model: viewModel.makeMasterPasswordLocalViewModel())
          .toolbar { ToolbarItem(placement: .navigationBarLeading) { cancelButton } }
          .navigationBarBackButtonHidden(viewModel.context.localLoginContext.isExtension)
      case let .biometry(biometry):
        BiometryView(model: viewModel.makeBiometryViewModel(biometryType: biometry))
      case let .pincode(lock, biometry):
        LockPinCodeAndBiometryView(
          model: viewModel.makePinCodeViewModel(lock: lock, biometryType: biometry))
      case .sso:
        SSOUnlockView(model: viewModel.makeSSOUnlockViewModel())
      case let .passwordLessRecovery(recoverFromFailure):
        PasswordLessRecoveryView(
          model: viewModel.makePasswordLessRecoveryViewModel(recoverFromFailure: recoverFromFailure)
        )
      }
    }

    @ViewBuilder
    private var cancelButton: some View {
      if case let .autofillExtension(cancelAction) = viewModel.context.localLoginContext {
        NavigationBarButton(
          action: {
            cancelAction()
          },
          title: L10n.Core.cancel)
      }
    }
  }
#endif
