import CoreLocalization
import CoreTypes
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
    .listStyle(.ds.insetGrouped)
    .navigationBarBackButtonHidden(true)
    .navigationTitle(L10n.Localizable.kwTitle)
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        Button(CoreL10n.cancel, action: model.cancel)
      }
      ToolbarItem(placement: .navigationBarTrailing) {
        Button(L10n.Localizable.kwSignupButton, action: model.signup)
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

      Button(CoreL10n.createaccountPrivacysettingsTermsConditions) {
        openURL(DashlaneURLFactory.Endpoint.tos.url)
      }
      .buttonStyle(.externalLink)
      .controlSize(.small)

      Button(CoreL10n.kwCreateAccountPrivacy) {
        openURL(DashlaneURLFactory.Endpoint.privacy.url)
      }
      .buttonStyle(.externalLink)
      .controlSize(.small)
    }
    .alert(
      L10n.Localizable.createaccountprivacysettingsError,
      isPresented: $model.shouldDisplayMissingRequiredConsentAlert,
      actions: {
        Button(CoreL10n.kwButtonOk) {}
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
