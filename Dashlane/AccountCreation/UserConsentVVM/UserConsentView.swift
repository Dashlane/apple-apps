import Combine
import CoreLocalization
import CoreSession
import DashTypes
import DesignSystem
import Foundation
import LoginKit
import SwiftUI
import UIComponents
import UIDelight

struct UserConsentView<TopSection: View>: View {
  @StateObject
  var model: UserConsentViewModel

  let topSection: TopSection

  init(
    model: @autoclosure @escaping () -> UserConsentViewModel,
    @ViewBuilder topSection: () -> TopSection
  ) {
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
      .navigationBarStyle(.alternate)
  }

  private var mainView: some View {
    List {
      topSection
        .listRowBackground(Color.ds.container.agnostic.neutral.supershy)
      consentSection
        .listRowBackground(Color.ds.container.agnostic.neutral.supershy)
    }
    .listAppearance(.insetGrouped)
    .safeAreaInset(edge: .bottom, alignment: .center) {
      createButton
    }
  }

  private var consentSection: some View {
    Section {
      DS.Toggle(isOn: $model.hasUserAcceptedTermsAndConditions.animation()) {
        Text(model.legalNoticeEUString)
      }
      .accessibility(identifier: "Terms Of Service checkbox")
      .fiberAccessibilityLabel(
        Text(L10n.Localizable.minimalisticOnboardingRecapCheckboxAccessibilityTitle)
      )
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
      .fiberAccessibilityLabel(
        Text(L10n.Localizable.createaccountPrivacysettingsMailsForTipsAccessibility)
      )
      .padding(.bottom, 8)

      Button(CoreLocalization.L10n.Core.kwCreateAccountTermsConditions) { model.goToTerms() }
        .buttonStyle(.externalLink)
        .controlSize(.small)
        .accessibilityAddTraits(.isLink)
        .accessibilityRemoveTraits(.isButton)

      Button(CoreLocalization.L10n.Core.kwCreateAccountPrivacy) { model.goToPrivacy() }
        .buttonStyle(.externalLink)
        .controlSize(.small)
        .accessibilityAddTraits(.isLink)
        .accessibilityRemoveTraits(.isButton)
    }
    .listRowSeparator(.hidden)
  }

  private var createButton: some View {
    Button(
      action: {
        model.validate()
      },
      label: {
        Text(L10n.Localizable.AccountCreation.Finish.createButton)
          .fixedSize(horizontal: false, vertical: true)
      }
    )
    .buttonStyle(.designSystem(.titleOnly))
    .buttonDisplayProgressIndicator(model.isAccountCreationRequestInProgress)
    .padding(.horizontal, 24)
    .padding(.bottom, 35)
    .disabled(model.isAccountCreationRequestInProgress)
  }

  private func userConsentAlert() -> Alert {
    Alert(title: Text(L10n.Localizable.createaccountprivacysettingsError))
  }

}

struct UserConsentView_Previews: PreviewProvider {

  static var previews: some View {
    MultiContextPreview {
      UserConsentView(
        model: UserConsentViewModel(userCountryProvider: .mock(userCountryInfos: .usa)) { _ in

        }
      ) {

      }
      UserConsentView(
        model: UserConsentViewModel(userCountryProvider: .mock(userCountryInfos: .france)) { _ in

        }
      ) {

      }
    }
  }
}
