import Foundation
import SwiftUI
import UIDelight
import LoginKit
import UIComponents
import DesignSystem

struct DWMRegistrationInGuidedOnboardingView: View {

    enum Action {
        case back
        case skip
        case mailAppOpened
        case userIndicatedEmailConfirmed
        case unexpectedError
    }

    @ObservedObject
    var viewModel: DWMRegistrationInGuidedOnboardingViewModel

    let action: (Action) -> Void

    var body: some View {
        FullScreenScrollView {
            VStack(spacing: 0) {
                headerView
                menuView
            }
        }
        .loginAppearance(backgroundColor: .ds.background.default)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationBarButton(L10n.Localizable.darkWebMonitoringOnboardingEmailViewBack) {
                    if viewModel.canGoBack() {
                        action(.back)
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationBarButton(L10n.Localizable.darkWebMonitoringOnboardingEmailViewSkip) {
                    viewModel.skip()
                    action(.skip)
                }
                .hidden(viewModel.shouldShowRegistrationRequestSent)
            }
        }
        .navigationBarStyle(.transparent)
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
        DWMRegistrationMenuView(viewModel: viewModel, action: action)
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
            Image.ds.item.email.outlined
                .renderingMode(.template)
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(.ds.text.positive.quiet)
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
            Image.ds.feedback.success.outlined
                .renderingMode(.template)
                .resizable()
                .frame(width: 16, height: 16)
                .foregroundColor(.ds.text.positive.quiet)
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

struct DWMOnboardingEmailView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview(deviceRange: .some([.iPhoneSE, .iPhone11]), dynamicTypePreview: true) {
            DWMRegistrationInGuidedOnboardingView(viewModel: .mock()) { _ in }
            DWMRegistrationInGuidedOnboardingView(viewModel: .mock()) { _ in }
        }
    }
}
