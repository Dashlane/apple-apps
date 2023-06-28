import Foundation
import DashTypes
import SwiftUI
import Combine
import CoreSession
import UIDelight
import LoginKit
import UIComponents
import DesignSystem
import CoreLocalization

struct UserConsentView<TopSection: View>: View {
    @StateObject
    var model: UserConsentViewModel

    let topSection: TopSection

    init(model: @autoclosure @escaping () -> UserConsentViewModel, @ViewBuilder topSection: () -> TopSection) {
        self._model = .init(wrappedValue: model())
        self.topSection = topSection()
    }

    var body: some View {
        mainView
            .loginAppearance()
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationBarButton(action: model.back, title: CoreLocalization.L10n.Core.kwBack)
                }
            }
            .navigationTitle(L10n.Localizable.kwTitle)
            .reportPageAppearance(.accountCreationTermsServices)
    }

    private var mainView: some View {
        List {
            topSection
            consentSection
        }
        .scrollContentBackground(.hidden)
        .safeAreaInset(edge: .bottom, alignment: .center) {
            createButton
        }
    }

    private var consentSection: some View {
        Section {
            DS.Toggle(isOn: $model.hasUserAcceptedTermsAndConditions.animation()) {
                Text(model.legalNoticeEUAttributedString)
            }
            .accessibility(identifier: "Terms Of Service checkbox")
            .fiberAccessibilityLabel(Text(L10n.Localizable.minimalisticOnboardingRecapCheckboxAccessibilityTitle))
            .alert(
                isPresented: $model.shouldDisplayMissingRequiredConsentAlert,
                content: userConsentAlert
            )
            .padding(.top, 8)

            DS.Toggle(
                L10n.Localizable.createaccountPrivacysettingsMailsForTips,
                isOn: $model.hasUserAcceptedEmailMarketing
            )
            .accessibility(identifier: "Send emails for tips checkbox")
            .fiberAccessibilityLabel(Text(L10n.Localizable.createaccountPrivacysettingsMailsForTipsAccessibility))
            .padding(.bottom, 8)
        }
        .listRowSeparator(.hidden)
    }

    private var createButton: some View {
        RoundedButton(L10n.Localizable.AccountCreation.Finish.createButton, action: model.validate)
            .roundedButtonLayout(.fill)
            .roundedButtonDisplayProgressIndicator(model.isAccountCreationRequestInProgress)
            .padding(.horizontal, 24)
            .padding(.bottom, 35)
            .opacity(model.hasUserAcceptedTermsAndConditions ? 1 : 0.8)
            .disabled(model.isAccountCreationRequestInProgress)
    }

    private func userConsentAlert() -> Alert {
        Alert(title: Text(L10n.Localizable.createaccountprivacysettingsError))
    }

}

extension UserConsentView: NavigationBarStyleProvider {
    var navigationBarStyle: UIComponents.NavigationBarStyle {
        .transparent(tintColor: FiberAsset.dashGreenCopy.color, statusBarStyle: .default)
    }
}

struct UserConsentView_Previews: PreviewProvider {

    static var previews: some View {
        MultiContextPreview {
            UserConsentView(
                model: UserConsentViewModel(
                    isEmailMarketingOptInRequired: true
                ) { _ in }
            ) {

            }
            UserConsentView(
                model: UserConsentViewModel(
                    isEmailMarketingOptInRequired: false
                ) { _ in }
            ) {

            }
        }
    }
}
