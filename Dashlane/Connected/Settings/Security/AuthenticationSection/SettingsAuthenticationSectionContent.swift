import SwiftTreats
import SwiftUI

struct SettingsAuthenticationSectionContent: View {

  struct ViewModels {
    let biometricToggleViewModel: SettingsBiometricToggleViewModel
    let pinCodeViewModel: PinCodeSettingsViewModel
    let rememberMasterPasswordToggleViewModel: RememberMasterPasswordToggleViewModel
  }

  let viewModels: ViewModels

  var body: some View {
    if Device.biometryType != nil {
      SettingsBiometricToggle(viewModel: viewModels.biometricToggleViewModel)
    }

    PinCodeSettingsView(viewModel: viewModels.pinCodeViewModel)

    if Device.is(.mac) {
      RememberMasterPasswordToggle(viewModel: viewModels.rememberMasterPasswordToggleViewModel)
    }
  }
}

struct SettingsAuthenticationSectionContent_Previews: PreviewProvider {
  static var previews: some View {
    SettingsAuthenticationSectionContent(viewModels: .mock)
  }
}

extension SettingsAuthenticationSectionContent.ViewModels {

  static var mock: SettingsAuthenticationSectionContent.ViewModels {
    .init(
      biometricToggleViewModel: .mock,
      pinCodeViewModel: .mock,
      rememberMasterPasswordToggleViewModel: .mock)
  }
}
