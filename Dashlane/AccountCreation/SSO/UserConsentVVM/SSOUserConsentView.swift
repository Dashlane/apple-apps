import Foundation
import SwiftUI
import UIDelight
import LoginKit
import UIComponents

struct SSOUserConsentView: View {

    @ObservedObject
    var model: SSOUserConsentViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            Text(L10n.Localizable.createaccountPrivacysettingsHeadline)
                .font(.headline)
                .padding(.horizontal, 16)

            consentCheckboxes
                .padding(.horizontal, 24)
            Spacer()
        }
        .padding(.top, 34)
        .navigationBarBackButtonHidden(true)
        .navigationTitle(L10n.Localizable.kwTitle)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationBarButton(action: model.cancel, title: L10n.Localizable.cancel)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationBarButton(action: model.signup, title: L10n.Localizable.kwSignupButton)
                    .disabled(model.isAccountCreationRequestInProgress)
            }
        }
        .loginAppearance()
    }

    private var consentCheckboxes: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(alignment: .center, spacing: 10) {
                Image(asset: model.hasUserAcceptedTermsAndConditions ? FiberAsset.checkboxSelected : FiberAsset.checkboxUnselected)
                    .onTapGesture {
                        self.model.hasUserAcceptedTermsAndConditions.toggle()
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
                        self.model.hasUserAcceptedEmailMarketing.toggle()
                    }
                    .fiberAccessibilityLabel(Text(L10n.Localizable.createaccountPrivacysettingsMailsForTipsAccessibility))
                    .fiberAccessibilityAddTraits(.isButton)
                    .fiberAccessibilityRemoveTraits(.isImage)
                    .accessibility(identifier: "Send emails for tips checkbox")
                Text(L10n.Localizable.createaccountPrivacysettingsMailsForTips).font(.body)
            }
        }
    }

    private func userConsentAlert() -> Alert {
        return Alert(title: Text(L10n.Localizable.createaccountprivacysettingsError))
    }
}

extension SSOUserConsentView: NavigationBarStyleProvider {
    var navigationBarStyle: NavigationBarStyle {
        return .transparent(tintColor: FiberAsset.dashGreenCopy.color, statusBarStyle: .default)
    }
}

struct SSOUserConsentView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            Group {
                NavigationView {
                    SSOUserConsentView(model: SSOUserConsentViewModel(isEmailMarketingOptInRequired: true,
                                                                      completion: {_ in
                    }))
                }
                SSOUserConsentView(model: SSOUserConsentViewModel(isEmailMarketingOptInRequired: false,
                                                                  completion: {_ in
                }))
            }

        }

    }
}
