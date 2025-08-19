import CoreLocalization
import CoreSession
import DesignSystem
import SwiftUI
import UIComponents
import UIDelight

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
        .loading(viewModel.isLoadingAccount)
    }
    .animation(.default, value: viewModel.unlockMode)
  }

  @ViewBuilder
  private var unlockView: some View {
    switch viewModel.unlockMode {
    case let .masterPassword(biometry, unlockMode):
      MasterPasswordLocalView(
        model: viewModel.makeMasterPasswordLocalViewModel(
          biometry: biometry, unlockMode: unlockMode)
      )
      .toolbar { ToolbarItem(placement: .navigationBarLeading) { cancelMPButton } }
      .navigationBarBackButtonHidden(viewModel.context.localLoginContext.isExtension)
    case let .biometry(biometry, accountType):
      BiometryView(
        model: viewModel.makeBiometryViewModel(biometryType: biometry, accountType: accountType))
    case let .pincode(lock, biometry, accountType):
      PinCodeAndBiometryView(
        model: viewModel.makePinCodeAndBiometryViewModel(
          lock: lock, accountType: accountType, biometryType: biometry))
    case let .sso(deviceAccessKey):
      SSOUnlockView(model: viewModel.makeSSOUnlockViewModel(deviceAccessKey: deviceAccessKey))
    case let .passwordLessRecovery(recoverFromFailure):
      PasswordLessRecoveryView(
        model: viewModel.makePasswordLessRecoveryViewModel(recoverFromFailure: recoverFromFailure))
    case .none:
      EmptyView()
    }
  }

  @ViewBuilder
  private var cancelMPButton: some View {
    if case let .autofillExtension(cancelAction) = viewModel.context.localLoginContext {
      Button(CoreL10n.cancel) {
        cancelAction()
      }
    }
  }
}
