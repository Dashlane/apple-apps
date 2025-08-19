import Combine
import CoreKeychain
import CorePersonalData
import CoreSession
import CoreSettings
import CoreTypes
import Logger
import LoginKit
import SwiftUI
import UIComponents
import UIDelight

struct LockView: View {
  @StateObject
  var viewModel: LockViewModel

  public init(viewModel: @autoclosure @escaping () -> LockViewModel) {
    self._viewModel = .init(wrappedValue: viewModel())
  }

  var body: some View {
    NavigationView {
      switch self.viewModel.mode {
      case .privacyShutter:
        VStack {
          LoginLogo()
            .fixedSize()
          Spacer()
        }
        .padding(.top, 20)
        .loginAppearance()
      case let .masterPassword(model):
        MasterPasswordLocalView(model: model)
      case let .biometry(model):
        BiometryView(model: model)
      case let .pinCode(model):
        PinCodeAndBiometryView(model: model)
      case .sso:
        SSOUnlockView(model: viewModel.makeSSOUnlockViewModel())
      case let .passwordLessRecovery(recoverFromFailure):
        PasswordLessRecoveryView(
          model: viewModel.makePasswordLessRecoveryViewModel(recoverFromFailure: recoverFromFailure)
        )
      }
    }
    .navigationViewStyle(.stack)
    .animation(.default, value: viewModel.lock)
    .fullScreenCover(item: $viewModel.newMasterPassword) { newMasterPassword in
      PostARKChangeMasterPasswordView(
        model: viewModel.makePostARKChangeMasterPasswordViewModel(
          newMasterPassword: newMasterPassword))
    }
  }
}
