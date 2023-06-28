import Foundation
import SwiftUI
import DesignSystem
import LoginKit
import CoreLocalization

struct AccountRecoveryKeyStatusDetailView: View {

    @StateObject
    var model: AccountRecoveryKeyStatusDetailViewModel

    @State
    var showAlert = false

    var body: some View {
         List {
            Section(footer: Text(L10n.Localizable.recoveryKeySettingsFooter).textStyle(.body.helper.regular)) {
                DS.Toggle(CoreLocalization.L10n.Core.recoveryKeySettingsLabel, isOn: $model.isEnabled)
            }
            .onTapGesture {
                if !model.isEnabled {
                    model.presentedSheet = .activation
                } else {
                    showAlert = true
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(CoreLocalization.L10n.Core.recoveryKeySettingsLabel)
        .fullScreenCover(item: $model.presentedSheet, onDismiss: {
            model.fetchStatus()
        }, content: { item in
            switch item {
            case .activation:
                AccountRecoveryActivationFlow(model: model.makeAccountRecoveryActivationFlowModel())
            case .error:
                FeedbackView(title: CoreLocalization.L10n.Core.kwExtSomethingWentWrong, message: CoreLocalization.L10n.Core.recoveryKeyActivationFailureMessage, primaryButton: (CoreLocalization.L10n.Core.modalTryAgain, {
                    model.deactivate()
                }), secondaryButton: (CoreLocalization.L10n.Core.cancel, {
                    model.presentedSheet = nil
                }))
            }

        })
        .alert(isPresented: $showAlert) {
            Alert(title: Text(L10n.Localizable.recoveryKeyDeactivationAlertTitle),
                  message: Text(L10n.Localizable.recoveryKeyDeactivationAlertMessage),
                  primaryButton: .default(Text(CoreLocalization.L10n.Core.cancel), action: { model.isEnabled.toggle() }),
                  secondaryButton: .destructive(Text(L10n.Localizable.recoveryKeyDeactivationAlertCta), action: model.deactivate))
        }
    }
}

struct AccountRecoveryKeyStatusDetailView_Previews: PreviewProvider {
    static var previews: some View {
        AccountRecoveryKeyStatusDetailView(model: AccountRecoveryKeyStatusDetailViewModel.mock)
    }
}
