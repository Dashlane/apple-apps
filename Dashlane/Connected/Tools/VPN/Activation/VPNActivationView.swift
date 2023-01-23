import SwiftUI
import UIComponents
import UIDelight
import DesignSystem

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
                    .font(.custom(GTWalsheimPro.bold.name, size: 26, relativeTo: .title).weight(.medium))

                Text(L10n.Localizable.vpnActivationViewEmailSubtitle)
                    .font(.body)
                    .foregroundColor(Color(asset: FiberAsset.neutralText))
                    .padding(.top, 8)
                Button(action: model.contactSupport, label: {
                    Text(L10n.Localizable.shushDashlaneLearnMore)
                        .underline()
                        .foregroundColor(Color(asset: SharedAsset.midGreen))
                }).padding(.top, 4)

            }.padding(16)

            VStack(alignment: .leading, spacing: 4) {
                TextInput("",
                          text: $model.email)
                .style(intensity: .supershy)
                .focused($isEditingEmail)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding(.horizontal, 16)
                .textInputLabel(L10n.Localizable.kwEmailIOS)
                                .background(Color.ds.container.agnostic.neutral.quiet.padding(.top, -8))
                .onAppear {
                    self.isEditingEmail = true
                }

                Text(L10n.Localizable.vpnActivationViewErrorWrongEmailFormat)
                    .foregroundColor(.ds.text.danger.quiet)
                    .font(.footnote)
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .hidden(model.isEmailAddressValid)
            }.padding(.bottom, 16)

            HStack(alignment: .center, spacing: 10) {
                Image(asset: model.hasUserAcceptedTermsAndConditions ? FiberAsset.checkboxSelected : FiberAsset.checkboxUnselected)
                    .onTapGesture {
                        model.hasUserAcceptedTermsAndConditions.toggle()
                    }

                Text(model.legalNoticeAttributedString)

            }.padding(.horizontal, 16)

            Spacer()

            RoundedButton(L10n.Localizable.kwConfirmButton,
                          action: { withAnimation { model.activateEmail() } })
            .roundedButtonLayout(.fill)
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
                .font(.custom(GTWalsheimPro.bold.name, size: 26, relativeTo: .title).weight(.medium))
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
                .font(.custom(GTWalsheimPro.bold.name, size: 26, relativeTo: .title).weight(.medium))
                .padding(.top, 25)
        }.padding(.horizontal, 16)
    }

    @ViewBuilder
    private var errorView: some View {
        VStack(alignment: .center, spacing: 0) {
            Spacer()

            LottieView(.passwordChangerFail, loopMode: .playOnce)
                .frame(width: 64, height: 64, alignment: .center)
            Text(model.errorTitle ?? L10n.Localizable.deviceUnlinkAlertTitle)
                .font(.custom(GTWalsheimPro.bold.name, size: 26, relativeTo: .title).weight(.medium))
                .padding(.top, 25)

            Text(model.errorDescription ?? L10n.Localizable.vpnActivationViewGenericErrorSubtitle)
                .font(.body)
                .foregroundColor(Color(asset: FiberAsset.neutralText))
                .padding(.top, 8)
                .multilineTextAlignment(.center)

            Spacer()

            RoundedButton(L10n.Localizable.fetchFailTryAgain,
                          action: { model.activationState = .initial })
            .roundedButtonLayout(.fill)

            Button(action: { model.contactSupport() }, label: {
                Text(L10n.Localizable.vpnActivationViewErrorContactSupport)
            }).buttonStyle(BorderlessActionButtonStyle())
                .foregroundColor(Color(asset: FiberAsset.midGreen))

        }.padding(.horizontal, 16)
    }
}

struct VPNActivationView_Previews: PreviewProvider {
    static var previews: some View {
        VPNActivationView(model: VPNActivationViewModel.mock())
        VPNActivationView(model: VPNActivationViewModel.mock(activationState: .loading))
        VPNActivationView(model: VPNActivationViewModel.mock(activationState: .success))
        VPNActivationView(model: VPNActivationViewModel.mock(activationState: .error(VPNServiceError.userAlreadyHasAnAccountForProvider)))
    }
}
