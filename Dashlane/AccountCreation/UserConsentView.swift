import Foundation
import DashTypes
import SwiftUI
import Combine
import CoreSession
import UIDelight
import LoginKit
import UIComponents
import DesignSystem

struct UserConsentView: View {

    @ObservedObject
    var model: UserConsentViewModel

    var body: some View {
        mainView
            .loginAppearance()
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationBarButton(action: model.back, title: L10n.Localizable.kwBack)
                }
            }
            .navigationTitle(L10n.Localizable.kwTitle)
            .onAppear {
                self.model.logger.log(.recap(action: .shown))
            }
            .reportPageAppearance(.accountCreationTermsServices)
    }

    private var mainView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(L10n.Localizable.minimalisticOnboardingRecapTitle)
                .font(DashlaneFont.custom(24, .medium).font)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                .padding(.top, 72)

            passwordTextFields
            consentCheckboxes
            Spacer()
            signUpButton
        }
    }

    private var passwordTextFields: some View {
        VStack(spacing: 4) {
            LoginFieldBox {
                TextInput("",
                          text: $model.email)
            }

            LoginFieldBox {
                TextInput("",
                          text: $model.masterPassword)
                .textInputIsSecure(true)
            }
        }
        .style(intensity: .supershy)
        .textInputDisableEdition()
    }

    private var consentCheckboxes: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(alignment: .center, spacing: 10) {
                Image(asset: model.hasUserAcceptedTermsAndConditions ? FiberAsset.checkboxSelected : FiberAsset.checkboxUnselected)
                    .onTapGesture {
                        self.model.hasUserAcceptedTermsAndConditions = !self.model.hasUserAcceptedTermsAndConditions
                    }
                    .alert(isPresented: $model.shouldDisplayMissingRequiredConsentAlert, content: userConsentAlert)
                    .fiberAccessibilityLabel(Text(L10n.Localizable.minimalisticOnboardingRecapCheckboxAccessibilityTitle))
                    .accessibility(identifier: "Terms Of Service checkbox")
                    .fiberAccessibilityAddTraits(.isButton)
                    .fiberAccessibilityRemoveTraits(.isImage)

                Text(model.legalNoticeEUAttributedString)

            }
            HStack(alignment: .center, spacing: 15) {
                Image(asset: model.hasUserAcceptedEmailMarketing ? FiberAsset.checkboxSelected : FiberAsset.checkboxUnselected)
                    .onTapGesture {
                        self.model.hasUserAcceptedEmailMarketing = !self.model.hasUserAcceptedEmailMarketing
                    }
                    .fiberAccessibilityLabel(Text(L10n.Localizable.createaccountPrivacysettingsMailsForTipsAccessibility))
                    .fiberAccessibilityAddTraits(.isButton)
                    .fiberAccessibilityRemoveTraits(.isImage)
                    .accessibility(identifier: "Send emails for tips checkbox")
                Text(L10n.Localizable.createaccountPrivacysettingsMailsForTips)
                    .foregroundColor(.ds.text.neutral.standard)
                    .font(.body)
            }
        }.padding(.horizontal, 24)
            .padding(.top, 44)
    }

    private var signUpButton: some View {
        RoundedButton(L10n.Localizable.minimalisticOnboardingRecapCTA, action: model.validate)
            .roundedButtonLayout(.fill)
            .roundedButtonDisplayProgressIndicator(model.isAccountCreationRequestInProgress)
        .padding(.horizontal, 24)
        .padding(.bottom, 35)
        .opacity(model.hasUserAcceptedTermsAndConditions ? 1 : 0.8)
        .disabled(model.isAccountCreationRequestInProgress)
    }

    private func userConsentAlert() -> Alert {
        return Alert(title: Text(L10n.Localizable.createaccountprivacysettingsError))
    }

}

extension UserConsentView: NavigationBarStyleProvider {
    var navigationBarStyle: NavigationBarStyle {
        return .transparent(tintColor: FiberAsset.dashGreenCopy.color, statusBarStyle: .default)
    }
}

struct UserConsentView_Previews: PreviewProvider {

    static var logger = AccountCreationInstallerLogger(installerLogService: InstallerLogService.mock)

    static var previews: some View {
        MultiContextPreview {
            UserConsentView(model: UserConsentViewModel(email: "", masterPassword: "", isEmailMarketingOptInRequired: true, logger: logger) {_ in})
            UserConsentView(model: UserConsentViewModel(email: "", masterPassword: "", isEmailMarketingOptInRequired: false, logger: logger) {_ in})
        }
    }
}
