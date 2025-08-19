import CoreLocalization
import DashlaneAPI
import DesignSystem
import DesignSystemExtra
import SwiftUI
import SwiftUILottie
import UIComponents
import UIDelight

struct VPNActivationView: View {

  @ObservedObject var model: VPNActivationViewModel

  @Environment(\.colorScheme) var colorScheme

  @FocusState
  var isEditingEmail: Bool

  var body: some View {
    Group {
      switch model.activationState {
      case .initial: emailActivationView
      case .loading: loadingView
      case .success: successView
      case .error: errorView
      }
    }
    .navigationBarBackButtonHidden(!shouldDisplayNavigationBarBackButton)
  }

  private var shouldDisplayNavigationBarBackButton: Bool {
    switch model.activationState {
    case .initial:
      return true
    default:
      return false
    }
  }

  @ViewBuilder
  private var emailActivationView: some View {
    VStack {
      Spacer()
      VStack(alignment: .leading, spacing: 0) {
        Text(L10n.Localizable.vpnActivationViewEmailTitle)
          .textStyle(.title.section.medium)

        Text(L10n.Localizable.vpnActivationViewEmailSubtitle)
          .textStyle(.body.standard.regular)
          .foregroundStyle(Color.ds.text.neutral.quiet)
          .padding(.top, 8)
        Button(
          action: { model.contactSupport() },
          label: {
            Text(L10n.Localizable.shushDashlaneLearnMore)
              .underline()
              .foregroundStyle(Color.ds.text.brand.standard)
          }
        )
        .padding(.top, 4)

      }.padding(16)

      VStack(alignment: .leading, spacing: 4) {
        DS.TextField(CoreL10n.kwEmailIOS, text: $model.email)
          .focused($isEditingEmail)
          .keyboardType(.emailAddress)
          .autocapitalization(.none)
          .padding(.horizontal, 16)
          .background(Color.ds.container.agnostic.neutral.quiet.padding(.top, -8))
          .onAppear {
            self.isEditingEmail = true
          }

        if !model.isEmailAddressValid {
          Text(L10n.Localizable.vpnActivationViewErrorWrongEmailFormat)
            .foregroundStyle(Color.ds.text.danger.quiet)
            .font(.footnote)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
      }
      .padding(.bottom, 16)
      .containerContext(.list(.insetGrouped))

      HStack(alignment: .center, spacing: 10) {
        NativeCheckmarkIcon(isChecked: model.hasUserAcceptedTermsAndConditions)
          .frame(width: 30, height: 30)
          .onTapGesture {
            model.hasUserAcceptedTermsAndConditions.toggle()
          }

        Text(model.legalNoticeAttributedString)

      }.padding(.horizontal, 16)

      Spacer()

      Button(CoreL10n.kwConfirmButton) {
        withAnimation { model.activateEmail() }
      }
      .buttonStyle(.designSystem(.titleOnly))
      .padding(.horizontal, 16)
      .opacity(model.hasUserAcceptedTermsAndConditions ? 1.0 : 0.6)
      .disabled(!model.hasUserAcceptedTermsAndConditions)
      .padding(.bottom, 16)
      .reportPageAppearance(.toolsVpnPrivacyConsent)
    }
  }

  @ViewBuilder
  private var loadingView: some View {
    VStack(alignment: .center, spacing: 0) {
      LottieView(.passwordChangerLoading)
        .frame(width: 64, height: 64, alignment: .center)
      Text(L10n.Localizable.vpnActivationViewFinalizing)
        .textStyle(.specialty.spotlight.small)
        .padding(.top, 25)
    }
    .padding(.horizontal, 16)
  }

  @ViewBuilder
  private var successView: some View {
    VStack(alignment: .center, spacing: 0) {
      LottieView(.passwordChangerSuccess, loopMode: .playOnce)
        .frame(width: 64, height: 64, alignment: .center)
      Text(L10n.Localizable.vpnActivationViewAccountCreated)
        .textStyle(.specialty.spotlight.small)
        .padding(.top, 25)
    }.padding(.horizontal, 16)
  }

  @ViewBuilder
  private var errorView: some View {
    VStack(alignment: .center, spacing: 0) {
      Spacer()

      LottieView(.passwordChangerFail, loopMode: .playOnce)
        .frame(width: 64, height: 64, alignment: .center)
      Text(model.errorTitle ?? CoreL10n.deviceUnlinkAlertTitle)
        .textStyle(.title.section.medium)
        .padding(.top, 25)

      Text(model.errorDescription ?? L10n.Localizable.vpnActivationViewGenericErrorSubtitle)
        .textStyle(.body.standard.regular)
        .foregroundStyle(Color.ds.text.neutral.quiet)
        .padding(.top, 8)
        .multilineTextAlignment(.center)

      Spacer()

      Button(L10n.Localizable.fetchFailTryAgain) {
        model.activationState = .initial
      }
      .buttonStyle(.designSystem(.titleOnly))

      Button(
        action: { model.contactSupport() },
        label: {
          Text(L10n.Localizable.vpnActivationViewErrorContactSupport)
        }
      )
      .buttonStyle(.designSystem(.titleOnly))
      .style(intensity: .supershy)
    }
    .padding(.horizontal, 16)
  }
}

struct VPNActivationView_Previews: PreviewProvider {
  static func apiError(
    _ vpnError: DashlaneAPI.APIErrorCodes.Vpn
  ) -> Error {
    DashlaneAPI.APIError(
      requestId: "",
      errors: [
        .init(
          code: vpnError.rawValue,
          message: "",
          type: ""
        )
      ]
    )
  }
  static var previews: some View {
    VPNActivationView(model: VPNActivationViewModel.mock())
    VPNActivationView(model: VPNActivationViewModel.mock(activationState: .loading))
    VPNActivationView(model: VPNActivationViewModel.mock(activationState: .success))
    VPNActivationView(
      model: VPNActivationViewModel.mock(
        activationState: .error(self.apiError(.userAlreadyHasAnAccountForProvider))))
  }
}
