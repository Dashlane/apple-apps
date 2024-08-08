import AuthenticatorKit
import CoreLocalization
import CorePersonalData
import CoreUserTracking
import DashTypes
import DesignSystem
import SwiftTreats
import SwiftUI
import UIComponents
import UIDelight
import VaultKit

struct OTPExplorerView: View {

  @StateObject
  private var viewModel: OTPExplorerViewModel

  @Environment(\.report)
  var report

  @State private var isCredentialListExpanded: Bool = false

  init(viewModel: @autoclosure @escaping () -> OTPExplorerViewModel) {
    self._viewModel = .init(wrappedValue: viewModel())
  }

  var body: some View {
    ScrollView {
      VStack(spacing: 32) {
        main
        if !isCredentialListExpanded {
          faqSection
        }
      }.padding(16)
    }
    .animation(.easeOut, value: isCredentialListExpanded)
    .backgroundColorIgnoringSafeArea(.ds.background.default)
    .navigationTitle(L10n.Localizable.otpToolName)
    .navigationBarTitleDisplayMode(.inline)
  }

  @ViewBuilder
  private var main: some View {
    if viewModel.otpSupportedCredentials.isEmpty {
      noCompatibleLogins
    } else if viewModel.otpNotConfiguredCredentials.isEmpty {
      otpFullConfigured
    } else {
      otpCompatibleCredentials
    }
  }

  private var faqSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(L10n.Localizable.otpToolFaq)
        .foregroundColor(.ds.text.neutral.quiet)
        .font(.footnote)
        .fontWeight(.medium)
        .accessibilityAddTraits(.isHeader)
      FAQView(items: [
        FAQItem.authenticator,
        FAQItem.secondFactorAuthentication,
        FAQItem.help,
      ]) { _ in }
    }
  }

  private var otpFullConfigured: some View {
    VStack(spacing: 25) {
      Image.ds.healthPositive.outlined
        .resizable()
        .renderingMode(.template)
        .foregroundColor(.ds.text.brand.quiet)
        .frame(width: 96, height: 96)

      VStack(spacing: 8) {
        Text(L10n.Localizable.otpTool2fasetupForAll)
          .font(
            .custom(GTWalsheimPro.regular.name, size: 20, relativeTo: .largeTitle).weight(.medium)
          )
          .foregroundColor(.ds.text.neutral.catchy)
        Text(L10n.Localizable.otpTool2fasetupForAllSubtitle)
          .font(.body)
          .foregroundColor(.ds.text.neutral.standard)
          .multilineTextAlignment(.center)
      }
      Button(L10n.Localizable.otptoolAddLoginCta, action: viewModel.startAddCredentialFlow)
        .buttonStyle(.designSystem(.titleOnly))
    }
  }

  var credentialsList: some View {
    VStack(spacing: 0) {
      ExpandableForEach(
        Array(viewModel.otpNotConfiguredCredentials.enumerated()),
        id: \.element.id,
        threshold: 5,
        expanded: $isCredentialListExpanded,
        label: { credentialListExpansionLabel },
        content: { index, credential in
          VStack(spacing: 0) {
            if index != 0 {
              Divider()
            }
            ActionableVaultItemRow(model: viewModel.makeRowViewModel(credential: credential)) {
              viewModel.startSetupOTPFlow(for: credential)
            }
          }
          .padding(.horizontal, 16)
        }
      )
    }
    .background(RoundedRectangle(cornerRadius: 8).foregroundColor(.ds.background.default))
    .onChange(of: isCredentialListExpanded) { newValue in
      if newValue {
        report?(UserEvent.Click(button: .seeAll))
      }
    }
  }

  private var otpCompatibleCredentials: some View {
    VStack(alignment: .leading) {
      Text(L10n.Localizable.otpTool2faCompatibleLoginsTitle)
        .font(
          .custom(GTWalsheimPro.regular.name, size: 20, relativeTo: .largeTitle).weight(.medium)
        )
        .foregroundColor(.ds.text.neutral.catchy)
        .accessibilityAddTraits(.isHeader)
      credentialsList

      Button(CoreLocalization.L10n.Core._2faSetupCta) {
        viewModel.startSetupOTPFlow()
      }
      .buttonStyle(.designSystem(.titleOnly))
      .padding(.top, 24)
    }
  }

  private var credentialListExpansionLabel: some View {
    HStack(spacing: 3) {
      Text(
        isCredentialListExpanded ? L10n.Localizable.otpToolSeeLess : L10n.Localizable.otpToolSeeAll
      )
      .foregroundColor(.ds.text.brand.quiet)
      Image(systemName: isCredentialListExpanded ? "chevron.up" : "chevron.down")
        .foregroundColor(.ds.text.brand.standard)
    }
    .frame(height: 50)
    .font(.headline)
  }

  private var noCompatibleLogins: some View {
    VStack(spacing: 32) {
      Image(asset: FiberAsset.pictoAuthenticator)
        .resizable()
        .renderingMode(.template)
        .foregroundColor(.ds.text.brand.quiet)
        .frame(width: 84, height: 84)
      VStack(spacing: 8) {
        Text(L10n.Localizable.otpToolNo2faLogins)
          .font(
            .custom(GTWalsheimPro.regular.name, size: 20, relativeTo: .largeTitle).weight(.medium)
          )
          .foregroundColor(.ds.text.neutral.catchy)

        Text(L10n.Localizable.otpToolNo2faLoginsSubtitle)
          .font(.callout)
          .foregroundColor(.ds.text.neutral.standard)
      }
      VStack {
        Button(L10n.Localizable.otpToolAddCredentialCta, action: viewModel.startAddCredentialFlow)
          .buttonStyle(.designSystem(.titleOnly))
        Button(
          action: { viewModel.startSetupOTPFlow() },
          title: L10n.Localizable.otpToolSetupCta
        )
        .buttonStyle(BorderlessActionButtonStyle())
        .foregroundColor(.ds.text.neutral.standard)
      }
    }
  }
}

extension FAQItem {

  private static let helpCenter2FAURL = URL(string: "_")!
  private static let helpCenterContactURL = URL(string: "_")!

  static var authenticator: FAQItem {
    return .init(
      title: L10n.Localizable.otpToolFaqAuthenticatorTitle,
      description: .init(
        title: L10n.Localizable.otpToolFaqAuthenticatorDescription,
        link: .init(label: L10n.Localizable._2faSetupIntroLearnMore, url: helpCenter2FAURL)))
  }

  static var secondFactorAuthentication: FAQItem {
    return .init(
      title: L10n.Localizable.otpToolFaq2faTitle,
      description: .init(
        title: L10n.Localizable.otpToolFaq2faDescription,
        link: .init(label: L10n.Localizable.otpToolFaqLearnMoreLink, url: helpCenter2FAURL)))
  }

  static var help: FAQItem {
    return .init(
      title: L10n.Localizable.otpToolFaqHelpTitle,
      description: .init(
        title: L10n.Localizable.otpToolFaqHelpDescription,
        link: .init(label: L10n.Localizable.kwHelpCenter, url: helpCenterContactURL)))
  }

}

#Preview {
  OTPExplorerView(viewModel: .mock)
}
