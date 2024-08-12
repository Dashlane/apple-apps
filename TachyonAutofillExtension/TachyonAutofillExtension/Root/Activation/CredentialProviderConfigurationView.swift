import DesignSystem
import SwiftUI
import UIComponents

struct CredentialProviderConfigurationView: View {
  let completion: () -> Void

  @Environment(\.colorScheme)
  var colorScheme

  var body: some View {
    VStack(spacing: 60) {
      illustration

      instructions

      Button(L10n.Localizable.credentialProviderOnboardingActivatedBackButtonTitle) {
        self.completion()
      }
      .buttonStyle(.designSystem(.titleOnly))
    }
    .padding(.horizontal, 24)
    .backgroundColorIgnoringSafeArea(.ds.background.alternate)
  }

  private var instructions: some View {
    VStack(spacing: 26) {
      Text(L10n.Localizable.credentialProviderOnboardingActivatedTitle)
        .foregroundColor(.ds.text.neutral.catchy)
        .textStyle(.title.section.large)
        .multilineTextAlignment(.center)
      Text(L10n.Localizable.credentialProviderOnboardingActivatedBody)
        .foregroundColor(.ds.text.neutral.quiet)
        .textStyle(.body.standard.regular)
        .multilineTextAlignment(.center)
    }
  }

  private var illustration: some View {
    VStack(alignment: .leading) {
      SettingsRow(kind: .icloudKeychain)
      Rectangle()
        .frame(height: 0.5)
        .foregroundColor(.ds.border.neutral.standard.idle)
        .padding(.leading, 30)
      SettingsRow(kind: .dashlane)
    }
    .frame(maxWidth: .infinity)
    .padding(13)
    .background(illustrationBackground)
    .cornerRadius(8)
    .shadow(color: .black.opacity(0.15), radius: 10)
  }

  private var illustrationBackground: Color {
    colorScheme == .dark
      ? Color.ds.container.agnostic.neutral.standard : Color.ds.background.default
  }
}

private struct SettingsRow: View {

  enum RowKind {
    case dashlane
    case icloudKeychain

    var icon: Image {
      switch self {
      case .dashlane:
        return Image(asset: FiberAsset.dashlaneIcon)
      case .icloudKeychain:
        return Image(asset: FiberAsset.keyIcon)
      }
    }

    var label: String {
      switch self {
      case .dashlane:
        return "Dashlane"
      case .icloudKeychain:
        return "iCloud Keychain"
      }
    }

    var font: Font {
      switch self {
      case .dashlane:
        return .headline
      case .icloudKeychain:
        return .body
      }
    }

    var trailingIcon: Image? {
      switch self {
      case .dashlane:
        return .ds.checkmark.outlined
      default:
        return nil
      }

    }
  }

  let kind: RowKind

  var body: some View {
    HStack {
      kind.icon
        .resizable()
        .frame(width: 26, height: 26)
      Text(kind.label)
        .font(kind.font)
        .foregroundColor(.ds.text.neutral.catchy)
      Spacer()
      if let trailingIcon = kind.trailingIcon {
        trailingIcon
          .foregroundColor(.ds.text.brand.standard)
      }
    }
  }
}

struct CredentialProviderConfigurationView_Previews: PreviewProvider {
  static var previews: some View {
    CredentialProviderConfigurationView(completion: {})
  }
}
