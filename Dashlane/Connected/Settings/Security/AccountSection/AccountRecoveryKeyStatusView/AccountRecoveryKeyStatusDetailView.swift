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

  var body: some View {
    List {
      Section(footer: Text(model.footerLabel).textStyle(.body.helper.regular)) {
        DS.Toggle(CoreLocalization.L10n.Core.recoveryKeySettingsLabel, isOn: $model.isEnabled)
          .highPriorityGesture(
            TapGesture()
              .onEnded {
                if !model.isEnabled {
                  model.presentedSheet = .activation
                } else {
                  showAlert = true
                }
              }
          )
      }
      .listRowBackground(Color.ds.container.agnostic.neutral.supershy)
    }
    .listAppearance(.insetGrouped)
    .navigationTitle(CoreLocalization.L10n.Core.recoveryKeySettingsLabel)
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
            title: CoreLocalization.L10n.Core.kwExtSomethingWentWrong,
            message: CoreLocalization.L10n.Core.recoveryKeyActivationFailureMessage,
            primaryButton: (
              CoreLocalization.L10n.Core.modalTryAgain,
              {
                model.deactivate()
              }
            ),
            secondaryButton: (
              CoreLocalization.L10n.Core.cancel,
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
        Button(CoreLocalization.L10n.Core.cancel, role: .cancel) {
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
