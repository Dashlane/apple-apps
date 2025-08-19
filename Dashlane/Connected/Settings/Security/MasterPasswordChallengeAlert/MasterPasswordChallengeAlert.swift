import CoreLocalization
import CoreTypes
import DesignSystemExtra
import SwiftUI
import UIComponents
import UIDelight
import UserTrackingFoundation

struct MasterPasswordChallengeAlert: View {

  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.report) private var report

  @ObservedObject
  var viewModel: MasterPasswordChallengeAlertViewModel

  @State
  private var masterPasswordInput = ""

  var body: some View {
    ZStack {
      Rectangle()
        .fill(.black.opacity(colorScheme == .dark ? 0.48 : 0.2))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
      NativeTextFieldAlert(
        title: title,
        message: message,
        placeholder: CoreL10n.kwEnterYourMasterPassword,
        isSecure: true,
        textFieldInput: $masterPasswordInput,
        onSubmit: buttonAction
      ) {
        Button(CoreL10n.cancel, role: .cancel) {
          viewModel.completion(.cancelled)
        }

        Button(secondaryButtonTitle, action: buttonAction)
      }
    }
    .writingToolsDisabled()
    .ignoresSafeArea(.keyboard, edges: .bottom)
    .onAppear {
      report?(UserEvent.AskAuthentication(mode: .masterPassword, reason: .changeMasterPassword))
    }
    #if DEBUG
      .onAppear {
        if !ProcessInfo.isTesting {
          masterPasswordInput = TestAccount.password
        }
      }
    #endif
  }

  private func buttonAction() {
    if viewModel.masterPassword == masterPasswordInput {
      viewModel.completion(.validated)
    } else {
      viewModel.completion(.failed)
    }
  }

  private var title: String {
    switch viewModel.intent {
    case .changeMasterPassword:
      return L10n.Localizable.settingsMasterPasswordPrompt
    case .enableMasterPasswordReset:
      return L10n.Localizable.resetMasterPasswordActivationMasterPasswordChallengeTitle
    }
  }

  private var message: String? {
    switch viewModel.intent {
    case .changeMasterPassword:
      return nil
    case .enableMasterPasswordReset:
      return L10n.Localizable.resetMasterPasswordActivationMasterPasswordChallengeMessage
    }
  }

  private var secondaryButtonTitle: String {
    switch viewModel.intent {
    case .changeMasterPassword:
      return CoreL10n.kwButtonOk
    case .enableMasterPasswordReset:
      return L10n.Localizable.resetMasterPasswordActivationMasterPasswordChallengeEnable
    }
  }
}

#Preview("Change MP") {
  MasterPasswordChallengeAlert(
    viewModel: .mock(intent: .changeMasterPassword)
  )
}

#Preview("Enable MP Reset") {
  MasterPasswordChallengeAlert(
    viewModel: .mock(intent: .enableMasterPasswordReset)
  )
}
