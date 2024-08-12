import Combine
import CoreLocalization
import CoreNetworking
import CoreSession
import DashTypes
import DesignSystem
import LoginKit
import SwiftUI
import UIComponents

struct TwoFADeactivationView: View {

  @StateObject
  var model: TwoFADeactivationViewModel

  init(model: @autoclosure @escaping () -> TwoFADeactivationViewModel) {
    self._model = .init(wrappedValue: model())
  }

  @State
  var isLostOTPSheetDisplayed = false

  @Environment(\.dismiss)
  private var dismiss

  var body: some View {
    NavigationView {
      navigationContent
        .modifier(
          LostOTPSheetModifier(
            isLostOTPSheetDisplayed: $isLostOTPSheetDisplayed,
            useBackupCode: { code in Task { await model.useBackupCode(code) } },
            lostOTPSheetViewModel: model.lostOTPSheetViewModel,
            context: .disable2fa))
    }
  }

  var navigationContent: some View {
    ZStack {
      switch model.state {
      case .otpInput:
        mainView
      case .inProgress:
        ProgressionView(state: $model.progressState)
      case .failure:
        errorView
      case .twoFAEnforced:
        enforcementView
      }
    }
    .frame(maxWidth: .infinity)
    .onReceive(model.dismissPublisher) {
      dismiss()
    }
    .animation(.default, value: model.state)
    .animation(.default, value: model.isTokenError)
  }

  var mainView: some View {
    VStack(alignment: .leading, spacing: 32) {
      Text(L10n.Localizable.twofaDeactivationTitle)
        .font(
          .custom(
            GTWalsheimPro.regular.name,
            size: 28,
            relativeTo: .title
          )
          .weight(.medium)
        )
        .foregroundColor(.ds.text.neutral.catchy)
      otpField

      Button(
        action: {
          isLostOTPSheetDisplayed = true
        },
        label: {
          Text(L10n.Localizable.twofaDeactivationHelpTitle)
            .foregroundColor(.ds.text.neutral.quiet) + Text(" ")
            + Text(L10n.Localizable.twofaDeactivationHelpCta)
            .foregroundColor(.ds.text.brand.standard)
            .underline()
        })

      Spacer()
    }
    .padding(24)
    .navigationBarTitleDisplayMode(.inline)
    .navigationTitle(Text(L10n.Localizable.twofaStepsNavigationTitle))
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        NavigationBarButton(
          action: dismiss.callAsFunction, title: CoreLocalization.L10n.Core.cancel)
      }
      ToolbarItem(placement: .navigationBarTrailing) {
        NavigationBarButton(
          action: {
            Task {
              await model.disable(model.otpValue)
            }
          },
          label: {
            Text(CoreLocalization.L10n.Core.kwNext)
              .opacity(model.canValidate ? 1 : 0.5)
          }
        )
        .disabled(!model.canValidate)
      }
    }
  }

  var errorView: some View {
    FeedbackView(
      title: L10n.Localizable.twofaDeactivationErrorTitle,
      message: L10n.Localizable.twofaDeactivationErrorMessage,
      primaryButton: (
        L10n.Localizable.twofaActivationErrorCta,
        {
          dismiss()
        }
      ))
  }

  var otpField: some View {
    VStack(alignment: .leading, spacing: 4) {
      OTPField(otp: $model.otpValue)
        .otpFieldStyle(strokeColor: model.isTokenError ? .ds.border.danger.standard.idle : .clear)
      if model.isTokenError {
        Text(L10n.Localizable.twofaDeactivationIncorrectTokenErrorMessage)
          .multilineTextAlignment(.leading)
          .font(.callout)
          .foregroundColor(.ds.text.danger.quiet)
      }
    }
  }

  var enforcementView: some View {
    FeedbackView(
      title: L10n.Localizable.twofaDisableTitle,
      message: L10n.Localizable.twofaDisableMessage1,
      kind: .twoFA,
      primaryButton: (L10n.Localizable.twofaDisableCta, { model.state = .otpInput }),
      secondaryButton: (CoreLocalization.L10n.Core.cancel, { dismiss() }),
      accessory: {
        Text(L10n.Localizable.twofaDisableMessage2)
      })
  }
}

struct TwoFADeactivationView_Previews: PreviewProvider {

  static var previews: some View {
    TwoFADeactivationView(model: .mock(state: .otpInput))
    TwoFADeactivationView(model: .mock(state: .failure))
    TwoFADeactivationView(model: .mock(state: .inProgress))
    TwoFADeactivationView(model: .mock(state: .twoFAEnforced))
  }
}
