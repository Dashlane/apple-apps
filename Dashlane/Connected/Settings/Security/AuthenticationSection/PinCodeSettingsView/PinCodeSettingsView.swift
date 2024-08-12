import CoreLocalization
import DesignSystem
import LoginKit
import SwiftTreats
import SwiftUI

struct PinCodeSettingsView: View {

  @ObservedObject
  var viewModel: PinCodeSettingsViewModel

  var body: some View {
    if viewModel.canShowPin {
      DS.Toggle(L10n.Localizable.kwUsePinCode, isOn: $viewModel.isToggleOn.animation())
        .alert(using: $viewModel.activeAlert) { activeAlert in
          switch activeAlert {
          case .deviceNotProtected(let completion):
            return makeDeviceNotProtectedAlert(completion: completion)
          case .keychainStoredMasterPassword(let newPinCode, let completion):
            return makeKeychainStoredMasterPasswordAlert(
              forPinCode: newPinCode, completion: completion)
          case .biometryReplacement(let completion):
            return makeBiometryReplacementAlert(completion: completion)
          }
        }
        .onChange(of: viewModel.isToggleOn, perform: viewModel.handleToggleValueChange)
        .overFullScreen(
          isPresented: Binding(
            get: {
              viewModel.displayPinCodeSelection && !viewModel.canChangePinCode
            },
            set: { newValue, _ in
              viewModel.displayPinCodeSelection = newValue
            })
        ) {
          PinCodeSelection(model: viewModel.makePinCodeSelectionViewModel())
        }
    }

    if viewModel.canChangePinCode {
      Button(
        action: {
          viewModel.displayPinCodeSelection = true
        },
        label: {
          Text(CoreLocalization.L10n.Core.kwChangePinCode)
            .foregroundColor(.ds.text.neutral.standard)
            .textStyle(.body.standard.regular)
        }
      )
      .overFullScreen(isPresented: $viewModel.displayPinCodeSelection) {
        PinCodeSelection(model: viewModel.makePinCodeSelectionViewModel())
      }
    }
  }

  private func makeDeviceNotProtectedAlert(completion: @escaping () -> Void) -> Alert {
    Alert(
      title: Text(L10n.Localizable.kwDeviceNotProtectedAlertTitle),
      message: Text(L10n.Localizable.kwDeviceNotProtectedAlertBody),
      dismissButton: .cancel(Text(CoreLocalization.L10n.Core.kwButtonOk), action: completion))
  }

  private func makeKeychainStoredMasterPasswordAlert(
    forPinCode pinCode: String, completion: @escaping (Bool) -> Void
  ) -> Alert {
    let title =
      Device.biometryType == nil
      ? L10n.Localizable.kwKeychainPasswordMsgPinOnly
      : L10n.Localizable.kwKeychainPasswordMsg(Device.currentBiometryDisplayableName)
    return Alert(
      title: Text(title),
      message: nil,
      primaryButton: .cancel({ completion(false) }),
      secondaryButton: .default(Text(CoreLocalization.L10n.Core.kwButtonOk)) { completion(true) })
  }

  private func makeBiometryReplacementAlert(completion: @escaping (Bool) -> Void) -> Alert {
    let title = L10n.Localizable.kwReplaceBiometryTypeConfirmMsg(
      Device.currentBiometryDisplayableName)
    return Alert(
      title: Text(title),
      message: nil,
      primaryButton: .cancel(
        Text(CoreLocalization.L10n.Core.kwReplaceTouchidCancel), action: { completion(false) }),
      secondaryButton: .default(
        Text(CoreLocalization.L10n.Core.kwReplaceTouchidOk), action: { completion(true) }))
  }
}

struct PinCodeSettingsView_Previews: PreviewProvider {
  static var previews: some View {
    PinCodeSettingsView(
      viewModel: PinCodeSettingsViewModel(
        session: .mock,
        lockService: LockServiceMock(),
        userSpacesService: .mock(),
        actionHandler: { _ in }))
  }
}
