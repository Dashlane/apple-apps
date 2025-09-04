import Combine
import CoreLocalization
import CoreSession
import DesignSystem
import SwiftTreats
import SwiftUI

struct MasterPasswordResetActivationView: View {
  typealias Confirmed = Bool

  @ObservedObject
  var viewModel: MasterPasswordResetActivationViewModel

  @Binding
  var masterPasswordChallengeItem: MasterPasswordChallengeAlertViewModel?

  var body: some View {
    DS.Toggle(L10n.Localizable.resetMasterPasswordSettingsItemTitle, isOn: $viewModel.isToggleOn)
      .onChange(of: viewModel.isToggleOn) { _, newValue in
        viewModel.handleToggleValueChange(newValue: newValue)
      }
      .onChange(of: viewModel.displayMasterPasswordChallenge) { _, display in
        guard display else {
          masterPasswordChallengeItem = nil
          return
        }
        masterPasswordChallengeItem = viewModel.makeMasterPasswordChallengeAlertViewModel()
      }
      .alert(
        using: $viewModel.activeAlert,
        content: { alert in
          switch alert {
          case .wrongMasterPassword(let completion):
            return makeWrongPasswordAlert(completion: completion)
          case .biometricActivation(let completion):
            return makeBiometricActivationAlert(completion: completion)
          case .deactivation(let completion):
            return makeDeactivationAlert(completion: completion)
          }
        })
  }

  private func makeWrongPasswordAlert(completion: @escaping () -> Void) -> Alert {
    Alert(
      title: Text(L10n.Localizable.kwWrongMasterPasswordMessage),
      message: nil,
      dismissButton: .default(Text(CoreL10n.kwButtonOk), action: completion))
  }

  private func makeBiometricActivationAlert(completion: @escaping (Confirmed) -> Void) -> Alert {
    let biometryName = Device.currentBiometryDisplayableName
    let title = L10n.Localizable.resetMasterPasswordBiometricsRequiredDialogTitle(biometryName)
    let message = L10n.Localizable.resetMasterPasswordBiometricsRequiredDialogDescription(
      biometryName)
    let primaryButtonTitle = L10n.Localizable.resetMasterPasswordBiometricsRequiredDialogAccept
    let secondaryButtonTitle = L10n.Localizable.resetMasterPasswordBiometricsRequiredDialogCancel

    return Alert(
      title: Text(title),
      message: Text(message),
      primaryButton: .default(Text(primaryButtonTitle), action: { completion(true) }),
      secondaryButton: .cancel(Text(secondaryButtonTitle), action: { completion(false) }))
  }

  private func makeDeactivationAlert(completion: @escaping (Confirmed) -> Void) -> Alert {
    let title = L10n.Localizable.resetMasterPasswordResetDeactivationDialogTitle
    let primaryButtonTitle = L10n.Localizable.resetMasterPasswordResetDeactivationDialogCancel
    let secondaryButtonTitle = L10n.Localizable.resetMasterPasswordResetDeactivationDialogDisable

    return Alert(
      title: Text(title),
      message: nil,
      primaryButton: .cancel(Text(primaryButtonTitle), action: { completion(false) }),
      secondaryButton: .destructive(Text(secondaryButtonTitle), action: { completion(true) }))
  }
}

struct MasterPasswordResetActivationView_Previews: PreviewProvider {
  static var previews: some View {
    MasterPasswordResetActivationView(
      viewModel: .init(
        masterPassword: "_",
        resetMasterPasswordService: ResetMasterPasswordServiceMock(),
        lockService: LockServiceMock(),
        actionHandler: { _ in }),
      masterPasswordChallengeItem: .constant(nil))
  }
}
