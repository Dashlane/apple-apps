#if canImport(UIKit)
  import Foundation
  import SwiftUI
  import Combine
  import CoreSession
  import UIDelight
  import SwiftTreats
  import DashTypes
  import CoreNetworking
  import UIComponents
  import DesignSystem
  import CoreLocalization

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
            .navigationTitle(L10n.Core.kwLoginVcLoginButton)
            .navigationBarTitleDisplayMode(.inline)
            .loading(isLoading: model.inProgress, loadingIndicatorOffset: true)
            .onAppear {
              self.model.logOnAppear()
            }
        }
      }
      .animation(.default, value: model.showDuoPush)
    }

    @ViewBuilder
    var backButton: some View {
      switch model.context {
      case .passwordApp:
        BackButton(
          label: L10n.Core.kwBack,
          color: .ds.text.neutral.catchy,
          action: dismiss.callAsFunction)
      case let .autofillExtension(cancelAction):
        Button(
          action: {
            cancelAction()
          }, title: L10n.Core.cancel
        )
        .foregroundColor(.ds.text.neutral.standard)
      }
    }

    private var duoPushView: some View {
      GravityAreaVStack(
        top: LoginLogo(login: nil),
        center: Text(L10n.Core.duoChallengePrompt),
        bottom: Spacer(),
        spacing: 0
      )
      .loginAppearance()
      .onAppear {
        Task {
          await self.model.sendPush(.duo)
        }
      }
      .loading(isLoading: true, loadingIndicatorOffset: true)
    }

    @ViewBuilder
    private var totpView: some View {
      Group {
        if Device.isIpadOrMac {
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
          NavigationBarButton(
            action: self.validate,
            title: L10n.Core.kwNext
          )
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

          Button(action: validate, title: L10n.Core.kwNext)
            .buttonStyle(.login)
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
          Text(L10n.Core.kwOtpMessage)
            .font(.callout)
            .multilineTextAlignment(.leading)
            .lineLimit(nil)
          Spacer()
        }

        DS.TextField(
          L10n.Core.kwOtpPlaceholderText, text: $model.otp,
          actions: {
            DS.FieldAction.ClearContent(text: $model.otp)
          }
        )
        .fieldLabelPersistencyDisabled()
        .focused($isTextFieldFocused)
        .onSubmit {
          self.validate()
        }
        .keyboardType(.numberPad)
        .textInputAutocapitalization(.never)
        .submitLabel(.continue)
        .disabled(model.inProgress)
        .bubbleErrorMessage(text: $model.errorMessage)
        .copyErrorMessageAction(errorMessage: model.errorMessage)

        HStack {
          Button(
            action: { isLostOTPSheetDisplayed = true },
            label: {
              Text(L10n.Core.otpRecoveryCannotAccessCodes)
                .font(.subheadline.weight(.medium))
                .foregroundColor(.ds.text.neutral.standard)
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
      Button(
        action: {
          self.model.showDuoPush = true
        }, title: L10n.Core.duoChallengeButton
      )
      .foregroundColor(.ds.text.brand.standard)
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
      }
    }
  }
#endif
