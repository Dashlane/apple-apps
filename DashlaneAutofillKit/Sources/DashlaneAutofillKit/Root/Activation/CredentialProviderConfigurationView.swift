import CoreLocalization
import DesignSystem
import SwiftUI
import UIComponents

struct CredentialProviderConfigurationView: View {
  @Environment(\.colorScheme) var colorScheme

  let completion: () -> Void

  var body: some View {
    VStack(spacing: 0) {
      VStack(spacing: 60) {
        illustration

        instructions
      }
      .frame(maxHeight: .infinity)

      Button(L10n.Localizable.credentialProviderOnboardingActivatedBackButtonTitle) {
        self.completion()
      }
      .buttonStyle(.designSystem(.titleOnly))
    }
    .padding(24)
    .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
  }

  private var illustration: some View {
    VStack(alignment: .leading, spacing: 15) {

      SystemSettingsRow(
        title: L10n.Localizable.appleProviderApp,
        icon: .appleProviderApp,
        isEnabled: false
      )
      .padding(.trailing, 15)

      Rectangle()
        .frame(height: 0.5)
        .foregroundStyle(Color.ds.border.neutral.standard.idle)
        .padding(.leading, 40)

      SystemSettingsRow(
        title: "Dashlane",
        icon: Image(.Activation.dashlaneIcon),
        isEnabled: true
      )
      .padding(.trailing, 15)

    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 15)
    .padding(.leading, 15)
    .background(illustrationBackground)
    .cornerRadius(10)
    .shadow(color: .black.opacity(0.15), radius: 10)
    .allowsHitTesting(false)
    .accessibilityHidden(true)
  }

  private var instructions: some View {
    VStack(spacing: 26) {
      Text(L10n.Localizable.onboardingTitle)
        .foregroundStyle(Color.ds.text.neutral.catchy)
        .textStyle(.title.section.large)
        .multilineTextAlignment(.center)
        .font(.body)

      Text(L10n.Localizable.onboardingBody)
        .foregroundStyle(Color.ds.text.neutral.quiet)
        .textStyle(.body.standard.regular)
        .multilineTextAlignment(.center)
        .font(.headline)
    }
  }

  private var illustrationBackground: Color {
    colorScheme == .dark
      ? Color.ds.container.agnostic.neutral.standard : Color.ds.background.default
  }
}

private struct SystemSettingsRow: View {
  let title: String
  let icon: Image
  let isEnabled: Bool

  var body: some View {
    HStack(spacing: 13) {
      icon
        .resizable()
        .frame(width: 28, height: 28)

      Text(title)
        .foregroundStyle(Color.ds.text.neutral.catchy)

      Spacer()

      Toggle(isOn: .constant(isEnabled)) {}
    }
  }
}

extension Image {
  static var appleProviderApp: Image {
    if #available(iOS 18, *) {
      Image(.Activation.applePasswordApp)
    } else {
      Image(.Activation.keyChain)
    }
  }
}

extension L10n.Localizable {
  fileprivate static var onboardingTitle: String {
    if #available(iOS 18, *) {
      credentialProviderOnboardingPasswordsAppActivatedTitle
    } else {
      credentialProviderOnboardingActivatedTitle
    }
  }

  fileprivate static var onboardingBody: String {
    if #available(iOS 18, *) {
      credentialProviderOnboardingPasswordsAppActivatedBody
    } else {
      credentialProviderOnboardingActivatedBody
    }
  }

  fileprivate static var appleProviderApp: String {
    if #available(iOS 18, *) {
      credentialProviderOnboardingPasswordsAppName
    } else {
      "iCloud Keychain"
    }
  }
}

#Preview {
  CredentialProviderConfigurationView(completion: {})
}
