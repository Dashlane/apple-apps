import Foundation
import SwiftUI
import UIDelight
import LoginKit
import UIComponents
import DesignSystem

struct DWMEmailRegistrationInGuidedOnboardingView<Model: DWMRegistrationViewModelProtocol>: View {

    @ObservedObject
    var viewModel: Model

    var body: some View {
        FullScreenScrollView {
            VStack(spacing: 0) {
                headerView
                menuView
            }
        }
        .loginAppearance()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationBarButton(L10n.Localizable.darkWebMonitoringOnboardingEmailViewBack) {
                    viewModel.back()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationBarButton(L10n.Localizable.darkWebMonitoringOnboardingEmailViewSkip) {
                    viewModel.skip()
                }
                .hidden(viewModel.shouldShowRegistrationRequestSent)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            self.viewModel.updateProgressUponDisplay()
        }
    }

    @ViewBuilder
    private var headerView: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                stepsNumberingLabel

                Text(L10n.Localizable.darkWebMonitoringOnboardingEmailViewTitle)
                    .font(.custom(GTWalsheimPro.bold.name, size: 26, relativeTo: .title))
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 16.0)
                    .fixedSize()

                Text(L10n.Localizable.darkWebMonitoringOnboardingEmailViewSubtitle)
                    .font(.body)
                    .foregroundColor(.ds.text.neutral.quiet)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 30)

                if viewModel.shouldShowRegistrationRequestSent == false {
                    emailView
                } else {
                    registrationRequestSentView
                }

            }
            .background(.ds.background.default)
            .padding(EdgeInsets(top: 38, leading: 24, bottom: 24, trailing: 24))
        }
    }

    private var menuView: some View {
        DWMRegistrationMenuView(viewModel: viewModel, environment: .guidedOnboarding)
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding(.horizontal, 24)

    }

    private var stepsNumberingLabel: some View {
        Text(L10n.Localizable.guidedOnboardingNumberingLabel("3", "3").uppercased())
            .font(DashlaneFont.custom(20, .medium).font)
            .foregroundColor(.ds.text.brand.quiet)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.bottom, 8)
    }

    private var emailView: some View {
        HStack(spacing: 8) {
            Image(asset: FiberAsset.emailFieldMailIcon)
                .renderingMode(.template)
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(.ds.text.positive.standard)
            Text(viewModel.email)
                .font(.headline)
                .foregroundColor(.ds.text.positive.standard)
            Spacer()
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 16)
        .fixedSize(horizontal: false, vertical: true)
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
        .background(.ds.container.agnostic.neutral.standard)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var registrationRequestSentView: some View {
        VStack(spacing: 16) {
            registrationRequestSentTitleView
            confirmEmailFootnote
        }
    }

    private var registrationRequestSentTitleView: some View {
        HStack(spacing: 8) {
            Image(asset: FiberAsset.emailRegistrationCheckmark)
                .renderingMode(.template)
                .resizable()
                .frame(width: 16, height: 16)
                .foregroundColor(.ds.text.positive.standard)
            Text(L10n.Localizable.darkWebMonitoringOnboardingEmailViewSent)
                .font(.headline)
                .foregroundColor(.ds.text.positive.standard)
            Spacer()
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 16)
        .fixedSize(horizontal: false, vertical: true)
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
        .background(.ds.container.agnostic.neutral.standard)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var confirmEmailFootnote: some View {
        Text(L10n.Localizable.darkWebMonitoringOnboardingEmailViewConfirmEmail)
            .font(.footnote)
            .foregroundColor(.ds.text.neutral.quiet)
            .fixedSize(horizontal: false, vertical: true)
    }
}

 extension DWMEmailRegistrationInGuidedOnboardingView: NavigationBarStyleProvider {
    var navigationBarStyle: NavigationBarStyle {
        let appearance = UINavigationBarAppearance()
        appearance.shadowColor = .clear
        appearance.backgroundColor = .ds.background.default
        return .custom(appearance: appearance, tintColor: .ds.text.neutral.standard)
    }
 }

struct DWMOnboardingEmailView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview(deviceRange: .some([.iPhoneSE, .iPhone11]), dynamicTypePreview: true) {
            DWMEmailRegistrationInGuidedOnboardingView(viewModel: FakeDWMEmailRegistrationInGuidedOnboardingViewModel(registrationRequestSent: false))
            DWMEmailRegistrationInGuidedOnboardingView(viewModel: FakeDWMEmailRegistrationInGuidedOnboardingViewModel(registrationRequestSent: true))
        }
    }
}
