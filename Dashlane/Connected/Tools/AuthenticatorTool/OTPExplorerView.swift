import CoreLocalization
import DesignSystem
import SwiftUI
import UIDelight
import UserTrackingFoundation
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
    landingView
      .animation(.easeOut, value: isCredentialListExpanded)
      .navigationTitle(L10n.Localizable.otpToolName)
      .navigationBarTitleDisplayMode(.inline)
      .scrollContentBackgroundStyle(.alternate)
  }

  @ViewBuilder
  private var landingView: some View {
    switch viewModel.viewState {
    case .loading:
      EmptyView()
    case .intro:
      introView
    case .ready:
      otpListView
    }
  }

  private var introView: some View {
    ToolIntroView(
      icon: ExpressiveIcon(.ds.feature.authenticator.outlined),
      title: CoreL10n.AuthenticatorIntro.title
    ) {
      FeatureCard {
        FeatureRow(
          asset: ExpressiveIcon(.ds.vault.outlined),
          title: CoreL10n.AuthenticatorIntro.subtitle1,
          description: CoreL10n.AuthenticatorIntro.description1
        )

        FeatureRow(
          asset: ExpressiveIcon(.ds.protection.outlined),
          title: CoreL10n.AuthenticatorIntro.subtitle2,
          description: CoreL10n.AuthenticatorIntro.description2
        )

        FeatureRow(
          asset: ExpressiveIcon(.ds.feature.passwordHealth.outlined),
          title: CoreL10n.AuthenticatorIntro.subtitle3,
          description: CoreL10n.AuthenticatorIntro.description3
        )
      }

      Button {
        viewModel.startAddCredentialFlow()
      } label: {
        Label(
          CoreL10n.AuthenticatorIntro.cta,
          icon: .ds.arrowRight.outlined
        )
      }
      .buttonStyle(.designSystem(.iconTrailing(.sizeToFit)))
    }
  }

  private var otpListView: some View {
    ScrollView {
      VStack(spacing: 32) {
        main
        if !isCredentialListExpanded {
          faqSection
        }
      }
      .padding(16)
    }
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
        .foregroundStyle(Color.ds.text.neutral.quiet)
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
        .foregroundStyle(Color.ds.text.brand.quiet)
        .frame(width: 96, height: 96)

      VStack(spacing: 8) {
        Text(L10n.Localizable.otpTool2fasetupForAll)
          .textStyle(.title.section.medium)
          .foregroundStyle(Color.ds.text.neutral.catchy)
        Text(L10n.Localizable.otpTool2fasetupForAllSubtitle)
          .textStyle(.body.standard.regular)
          .foregroundStyle(Color.ds.text.neutral.standard)
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
    .background(RoundedRectangle(cornerRadius: 8).foregroundStyle(Color.ds.background.default))
    .onChange(of: isCredentialListExpanded) { _, newValue in
      if newValue {
        report?(UserEvent.Click(button: .seeAll))
      }
    }
  }

  private var otpCompatibleCredentials: some View {
    VStack(alignment: .leading) {
      Text(L10n.Localizable.otpTool2faCompatibleLoginsTitle)
        .textStyle(.title.section.medium)
        .foregroundStyle(Color.ds.text.neutral.catchy)
        .accessibilityAddTraits(.isHeader)
      credentialsList

      Button(CoreL10n._2faSetupCta) {
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
      .foregroundStyle(Color.ds.text.brand.quiet)
      Image(systemName: isCredentialListExpanded ? "chevron.up" : "chevron.down")
        .foregroundStyle(Color.ds.text.brand.standard)
    }
    .frame(height: 50)
    .font(.headline)
  }

  private var noCompatibleLogins: some View {
    VStack(spacing: 32) {
      Image.ds.feature.authenticator.outlined
        .resizable()
        .renderingMode(.template)
        .foregroundStyle(Color.ds.text.brand.quiet)
        .frame(width: 84, height: 84)
      VStack(spacing: 8) {
        Text(L10n.Localizable.otpToolNo2faLogins)
          .textStyle(.title.section.medium)
          .foregroundStyle(Color.ds.text.neutral.catchy)

        Text(L10n.Localizable.otpToolNo2faLoginsSubtitle)
          .textStyle(.body.standard.regular)
          .foregroundStyle(Color.ds.text.neutral.standard)
      }
      VStack {
        Button(L10n.Localizable.otpToolAddCredentialCta, action: viewModel.startAddCredentialFlow)
          .buttonStyle(.designSystem(.titleOnly))
        Button(L10n.Localizable.otpToolSetupCta) {
          viewModel.startSetupOTPFlow()
        }
        .buttonStyle(.designSystem(.titleOnly))
        .style(intensity: .supershy)
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
