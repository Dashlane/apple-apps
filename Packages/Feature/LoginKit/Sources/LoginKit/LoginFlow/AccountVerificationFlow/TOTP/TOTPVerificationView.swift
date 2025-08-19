import Combine
import CoreLocalization
import CoreNetworking
import CoreSession
import CoreTypes
import DesignSystem
import DesignSystemExtra
import Foundation
import SwiftTreats
import SwiftUI
import UIComponents
import UIDelight

struct TOTPVerificationView: View {

  @ObservedObject var model: TOTPVerificationViewModel

  @Environment(\.dismiss)
  private var dismiss

  @FocusState
  var isTextFieldFocused: Bool

  @State
  var isLostOTPSheetDisplayed = false

  var body: some View {
    ZStack {
      if model.showDuoPush {
        duoPushView.navigationBarHidden(true)
      } else {
        totpView
          .loginAppearance()
          .navigationTitle(CoreL10n.kwLoginVcLoginButton)
          .navigationBarTitleDisplayMode(.inline)
          .onAppear {
            self.model.logOnAppear()
          }
      }
    }
    .animation(.default, value: model.showDuoPush)
    .loading(model.inProgress)
  }

  @ViewBuilder
  var backButton: some View {
    switch model.context {
    case .passwordApp:
      NativeNavigationBarBackButton(
        CoreL10n.kwBack,
        action: dismiss.callAsFunction)
    case let .autofillExtension(cancelAction):
      Button(CoreL10n.cancel, action: cancelAction)
    }
  }

  private var duoPushView: some View {
    GravityAreaVStack(
      top: LoginLogo(login: nil),
      center: Text(CoreL10n.duoChallengePrompt),
      bottom: Spacer(),
      spacing: 0
    )
    .loginAppearance()
    .onAppear {
      Task {
        await self.model.sendPush(.duo)
      }
    }
  }

  @ViewBuilder
  private var totpView: some View {
    Group {
      if Device.is(.pad, .mac, .vision) {
        vStackIpadMac
      } else {
        vStackIphone
      }
    }
    .modifier(
      LostOTPSheetModifier(
        isLostOTPSheetDisplayed: $isLostOTPSheetDisplayed,
        useBackupCode: { model.useBackupCode($0) },
        lostOTPSheetViewModel: model.lostOTPSheetViewModel))
  }

  private var vStackIphone: some View {
    GravityAreaVStack(
      top: LoginLogo(login: self.model.login),
      center: self.calloutAndCodeField,
      bottom: VStack {
        if self.model.hasDuoPush {
          self.sendDuoPushButton
        }
      },
      spacing: 0
    )
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button(CoreL10n.kwNext, action: self.validate)
          .disabled(!self.model.canLogin)
      }
    }
  }

  private var vStackIpadMac: some View {
    VStack(alignment: .center, spacing: 0) {
      LoginLogo(login: self.model.login)

      calloutAndCodeField

      HStack {
        Spacer()

        Button(CoreL10n.kwNext, action: validate)
          .buttonStyle(.designSystem(.titleOnly))
          .frame(alignment: .center)
          .disabled(!self.model.canLogin)

        Spacer()
      }
      .padding(.top, 40)

      Spacer()
        .frame(maxHeight: .infinity)
    }
  }

  private var calloutAndCodeField: some View {
    VStack {
      HStack {
        Text(CoreL10n.kwOtpMessage)
          .font(.callout)
          .multilineTextAlignment(.leading)
          .lineLimit(nil)
        Spacer()
      }

      DS.TextField(
        CoreL10n.kwOtpPlaceholderText, text: $model.otp,
        actions: {
          DS.FieldAction.ClearContent(text: $model.otp)
        },
        feedback: {
          if let errorMessage = model.errorMessage {
            FieldTextualFeedback(errorMessage)
              .style(.error)
          }
        }
      )
      .fieldLabelHiddenOnFocus()
      .focused($isTextFieldFocused)
      .onSubmit {
        self.validate()
      }
      .keyboardType(.numberPad)
      .textInputAutocapitalization(.never)
      .submitLabel(.continue)
      .disabled(model.inProgress)
      .copyErrorMessageAction(errorMessage: model.errorMessage)

      HStack {
        Button(
          action: { isLostOTPSheetDisplayed = true },
          label: {
            Text(CoreL10n.otpRecoveryCannotAccessCodes)
              .font(.subheadline.weight(.medium))
              .foregroundStyle(Color.ds.text.neutral.standard)
              .underline()
          }
        )
        Spacer()
      }
      .padding(.horizontal)
      .onAppear {
        self.isTextFieldFocused = true
      }
    }
    .padding(.horizontal)
  }

  private var sendDuoPushButton: some View {
    Button(CoreL10n.duoChallengeButton) {
      self.model.showDuoPush = true
    }
    .foregroundStyle(Color.ds.text.brand.standard)
    .padding(5)
  }

  private func validate() {
    UIApplication.shared.endEditing()
    model.validate()
  }

}

struct TOTPVerificationView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      TOTPVerificationView(model: .mock)
    }.navigationViewStyle(.stack)
  }
}
