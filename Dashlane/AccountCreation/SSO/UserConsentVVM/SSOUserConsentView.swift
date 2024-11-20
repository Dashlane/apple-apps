import CoreLocalization
import DashTypes
import DesignSystem
import Foundation
import LoginKit
import SwiftUI
import UIComponents
import UIDelight

struct SSOUserConsentView: View {

  @Environment(\.openURL)
  var openURL

  @ObservedObject
  var model: SSOUserConsentViewModel

  var body: some View {
    List {
      Section {
        consentCheckboxes
          .listRowBackground(Color.ds.container.agnostic.neutral.supershy)
      }
    }
    .listAppearance(.insetGrouped)
    .navigationBarBackButtonHidden(true)
    .navigationTitle(L10n.Localizable.kwTitle)
    .navigationBarStyle(.alternate)
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        NavigationBarButton(action: model.cancel, title: CoreLocalization.L10n.Core.cancel)
      }
      ToolbarItem(placement: .navigationBarTrailing) {
        NavigationBarButton(action: model.signup, title: L10n.Localizable.kwSignupButton)
          .disabled(model.isAccountCreationRequestInProgress)
      }
    }
    .loginAppearance()
  }

  private var consentCheckboxes: some View {
    VStack(alignment: .leading, spacing: 12) {
      DS.Toggle(
        isOn: $model.hasUserAcceptedTermsAndConditions,
        label: {
          Text(model.legalNoticeEUString)
        }
      )
      .padding(.top, 8)
      .fiberAccessibilityLabel(
        Text(L10n.Localizable.minimalisticOnboardingRecapCheckboxAccessibilityTitle)
      )
      .accessibility(identifier: "Terms Of Service checkbox")

      DS.Toggle(
        isOn: $model.hasUserAcceptedEmailMarketing,
        label: {
          Text(L10n.Localizable.createaccountPrivacysettingsMailsForTips)
        }
      )
      .padding(.bottom, 8)
      .fiberAccessibilityLabel(
        Text(L10n.Localizable.createaccountPrivacysettingsMailsForTipsAccessibility)
      )
      .accessibility(identifier: "Send emails for tips checkbox")

      Button(CoreLocalization.L10n.Core.createaccountPrivacysettingsTermsConditions) {
        openURL(DashlaneURLFactory.Endpoint.tos.url)
      }
      .buttonStyle(.externalLink)
      .controlSize(.small)

      Button(CoreLocalization.L10n.Core.kwCreateAccountPrivacy) {
        openURL(DashlaneURLFactory.Endpoint.privacy.url)
      }
      .buttonStyle(.externalLink)
      .controlSize(.small)
    }
    .alert(
      L10n.Localizable.createaccountprivacysettingsError,
      isPresented: $model.shouldDisplayMissingRequiredConsentAlert,
      actions: {
        Button(CoreLocalization.L10n.Core.kwButtonOk) {}
      }
    )
  }
}

struct SSOUserConsentView_Previews: PreviewProvider {
  static var previews: some View {
    MultiContextPreview {
      Group {
        NavigationView {
          SSOUserConsentView(
            model: SSOUserConsentViewModel(
              userCountryProvider: .mock(userCountryInfos: .usa),
              completion: { _ in }
            )
          )
        }
        SSOUserConsentView(
          model: SSOUserConsentViewModel(
            userCountryProvider: .mock(userCountryInfos: .france),
            completion: { _ in }
          )
        )
      }

    }
  }
}
