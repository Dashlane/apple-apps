import CoreLocalization
import DesignSystem
import Foundation
import LoginKit
import SwiftUI
import UIComponents

struct AccountRecoveryConfirmationView: View {
  @Environment(\.dismiss)
  var dismiss

  @StateObject
  var model: AccountRecoveryConfirmationViewModel

  @State
  var showAlert = false

  init(model: @autoclosure @escaping () -> AccountRecoveryConfirmationViewModel) {
    self._model = .init(wrappedValue: model())
  }

  var body: some View {
    ZStack {
      mainView
      if model.inProgress {
        ProgressionView(state: $model.progressState)
      }
    }
    .animation(.default, value: model.progressState)
    .navigationTitle(CoreLocalization.L10n.Core.recoveryKeySettingsLabel)
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        if !model.inProgress {
          BackButton(color: .accentColor) {
            showAlert = true
          }
        }
      }
    }
    .navigationBarBackButtonHidden(true)
    .alert(
      isPresented: $showAlert,
      content: {
        Alert(
          title: Text(CoreLocalization.L10n.Core.accountRecoveryKeyCancelAlertTitle),
          message: Text(CoreLocalization.L10n.Core.accountRecoveryKeyCancelAlertMessage),
          primaryButton: Alert.Button.destructive(
            Text(CoreLocalization.L10n.Core.accountRecoveryKeyCancelAlertCta),
            action: {
              dismiss()
            }),
          secondaryButton: .cancel(
            Text(CoreLocalization.L10n.Core.accountRecoveryKeyCancelAlertCancelCta)))
      }
    )
    .loginAppearance()
  }

  var mainView: some View {
    ScrollView {
      recoveryKeyView
        .toolbar {
          ToolbarItem(placement: .navigationBarTrailing) {
            if !model.inProgress {
              Button(
                action: {
                  Task {
                    await model.activate()
                  }
                },
                label: {
                  Text(CoreLocalization.L10n.Core.kwNext)
                    .foregroundColor(.ds.text.brand.standard)
                })
            }
          }
        }
    }
    .scrollContentBackgroundStyle(.alternate)
  }

  var recoveryKeyView: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text(L10n.Localizable.recoveryKeyActivationConfirmationTitle)
        .multilineTextAlignment(.leading)
        .lineLimit(nil)
        .fixedSize(horizontal: false, vertical: true)
        .font(
          .custom(
            GTWalsheimPro.regular.name,
            size: 28,
            relativeTo: .title
          )
          .weight(.medium)
        )
        .foregroundColor(.ds.text.neutral.catchy)
      Text(L10n.Localizable.recoveryKeyActivationConfirmationMessage)
        .multilineTextAlignment(.leading)
        .lineLimit(nil)
        .fixedSize(horizontal: false, vertical: true)
        .foregroundColor(.ds.text.neutral.standard)
        .font(.body)
        .padding(.bottom, 16)
      AccountRecoveryKeyTextField(
        recoveryKey: $model.userRecoveryKey, showNoMatchError: $model.showNoMatchError
      )
      .onSubmit {
        Task {
          await model.activate()
        }
      }
      Spacer()
    }.padding(.all, 24)
      .padding(.bottom, 24)

  }
}

struct AccountRecoveryConfirmationView_Previews: PreviewProvider {
  static var previews: some View {
    AccountRecoveryConfirmationView(
      model: AccountRecoveryConfirmationViewModel(
        recoveryKey: "",
        accountRecoveryKeyService: .mock,
        activityReporter: .mock,
        completion: {}
      )
    )
    AccountRecoveryConfirmationView(
      model: AccountRecoveryConfirmationViewModel(
        recoveryKey: "NU6H7YTZDQNA2VQC6K56UIW1T7YN",
        userRecoveryKey: "NU6H-7YTZ-DQNA-2VQC-6K56-UIW1-T7YN",
        accountRecoveryKeyService: .mock,
        activityReporter: .mock,
        completion: {}
      )
    )
    AccountRecoveryConfirmationView(
      model: AccountRecoveryConfirmationViewModel(
        recoveryKey: "NU6H7YTZDQNA2VQC6K56UIW1T7YN",
        showNoMatchError: true,
        userRecoveryKey: "NU6H-7YTZ-DQNA-2VQC-6K56-UIW1-T7YN",
        accountRecoveryKeyService: .mock,
        activityReporter: .mock,
        completion: {}
      )
    )
  }
}
