import CoreLocalization
import DesignSystem
import Foundation
import LoginKit
import SwiftUI

struct PassphraseInputView: View {

  @StateObject
  var model: PassphraseInputViewModel

  @State
  var showCancelAlert = false

  init(model: @escaping @autoclosure () -> PassphraseInputViewModel) {
    self._model = .init(wrappedValue: model())
  }

  var body: some View {
    ZStack {
      if model.showError {
        FeedbackView(
          title: L10n.Localizable.Mpless.D2d.Trusted.limitErrorTitle,
          message: L10n.Localizable.Mpless.D2d.Trusted.limitErrorMessage,
          primaryButton: (
            L10n.Localizable.Mpless.D2d.Trusted.limitErrorCta,
            {
              model.gotoSettings()
            }
          )
        )
        .reportPageAppearance(.settingsAddNewDeviceAttemptLimitReached)
      } else {
        mainView
          .reportPageAppearance(.settingsAddNewDeviceSecurityChallenge)
      }
    }.animation(.default, value: model.showError)
  }

  var mainView: some View {
    VStack(spacing: 24) {
      Text(L10n.Localizable.Mpless.D2d.Universal.Trusted.passphraseTitle(model.deviceName))
        .textStyle(.title.section.large)
        .foregroundStyle(Color.ds.text.neutral.catchy)
      VStack(alignment: .leading, spacing: 24) {
        ForEach(model.passphrase.indices, id: \.self) { index in
          if index == model.indexField {
            DS.TextField(
              L10n.Localizable.Mpless.D2d.Universal.Trusted.passphraseLabel, text: $model.inputText
            )
            .style(mood: model.showNoMatchError ? .danger : .neutral)
            .autocorrectionDisabled()
            .autocapitalization(.none)
          } else {
            Text(model.passphrase[index])
              .textStyle(.body.standard.monospace)
              .foregroundStyle(Color.ds.text.neutral.catchy)
          }
        }
      }.padding(24)
        .background(
          RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color.ds.container.agnostic.neutral.supershy)
        )
      Spacer()
    }
    .padding(24)
    .backgroundColorIgnoringSafeArea(.ds.background.alternate)
    .navigationTitle(L10n.Localizable.Mpless.D2d.trustedNavigationTitle)
    .navigationBarTitleDisplayMode(.inline)
    .navigationBarBackButtonHidden()
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button(
          L10n.Localizable.Mpless.D2d.Universal.Trusted.passphraseConfirmCta,
          action: {
            model.validate()
          }
        )
        .foregroundColor(.ds.text.brand.standard)
      }
      ToolbarItem(placement: .topBarLeading) {
        Button(
          L10n.Localizable.Mpless.D2d.Universal.Trusted.passphraseCancelCta,
          action: {
            showCancelAlert = true
          }
        )
        .foregroundStyle(Color.ds.text.brand.standard)
      }
    }
    .alert(
      isPresented: $showCancelAlert,
      content: {
        Alert(
          title: Text(CoreLocalization.L10n.Core.Mpless.D2d.Trusted.cancelAlertTitle),
          message: Text(CoreLocalization.L10n.Core.Mpless.D2d.Trusted.cancelAlertMessage),
          primaryButton: Alert.Button.destructive(
            Text(CoreLocalization.L10n.Core.Mpless.D2d.Trusted.cancelAlertCta),
            action: {
              model.cancel()
            }),
          secondaryButton: .cancel(
            Text(CoreLocalization.L10n.Core.Mpless.D2d.Trusted.cancelAlertCancelCta)))
      })
  }
}

struct PassphraseInputView_Previews: PreviewProvider {

  static var previews: some View {
    NavigationView {
      PassphraseInputView(
        model: PassphraseInputViewModel(
          passphrase: ["One", "Two", "Three", "Four", "Five"], deviceName: "Dashlane's iPhone"
        ) { _ in })
    }
  }
}
