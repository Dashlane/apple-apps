import CoreLocalization
import DesignSystem
import Foundation
import LoginKit
import SwiftUI

struct AccountRecoveryKeyStatusDetailView: View {

  @StateObject
  var model: AccountRecoveryKeyStatusDetailViewModel

  @State
  var showAlert = false

  @Environment(\.accessControl)
  var accessControl

  var body: some View {
    List {
      Section(footer: Text(model.footerLabel).textStyle(.body.helper.regular)) {
        DS.Toggle(
          CoreL10n.recoveryKeySettingsLabel,
          isOn: Binding(
            get: { model.isEnabled },
            set: { newValue in
              accessControl.requestAccess(for: .authenticationSetup) { success in
                guard success else { return }

                if newValue {
                  model.presentedSheet = .activation
                  model.isEnabled = newValue
                } else {
                  showAlert = true
                }
              }
            }
          ))
      }
      .listRowBackground(Color.ds.container.agnostic.neutral.supershy)
    }
    .listStyle(.ds.insetGrouped)
    .navigationTitle(CoreL10n.recoveryKeySettingsLabel)
    .fullScreenCover(
      item: $model.presentedSheet,
      onDismiss: {
        model.fetchStatus()
      },
      content: { item in
        switch item {
        case .activation:
          AccountRecoveryActivationFlow(model: model.makeAccountRecoveryActivationFlowModel())
        case .error:
          FeedbackView(
            title: CoreL10n.kwExtSomethingWentWrong,
            message: CoreL10n.recoveryKeyActivationFailureMessage,
            primaryButton: (
              CoreL10n.modalTryAgain,
              {
                model.deactivate()
              }
            ),
            secondaryButton: (
              CoreL10n.cancel,
              {
                model.presentedSheet = nil
              }
            ))
        }

      }
    )
    .alert(
      L10n.Localizable.recoveryKeyDeactivationAlertTitle,
      isPresented: $showAlert,
      actions: {
        Button(CoreL10n.cancel, role: .cancel) {
          model.isEnabled = true
        }
        Button(L10n.Localizable.recoveryKeyDeactivationAlertCta, role: .destructive) {
          model.deactivate()
        }
      },
      message: {
        Text(L10n.Localizable.recoveryKeyDeactivationAlertMessage)
      }
    )
  }
}

struct AccountRecoveryKeyStatusDetailView_Previews: PreviewProvider {
  static var previews: some View {
    AccountRecoveryKeyStatusDetailView(model: AccountRecoveryKeyStatusDetailViewModel.mock)
  }
}
